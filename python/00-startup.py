# ~/.ipython/profile_default/startup/

# --- 核心系统库 ---
import os
import sys
import time
import math
import datetime
from operator import itemgetter, attrgetter
from functools import cache, lru_cache, partial
from itertools import chain, product, combinations, groupby

# --- 核心科学计算 ---
import numpy as np
import scipy as sp
import pandas as pd
import networkx as nx
import matplotlib as mpl
import matplotlib.pyplot as plt

# --- 深度学习生态 ---
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim


# --- 配置设定 ---
pd.options.display.max_columns = 100
pd.options.display.max_rows = 100

plt.style.use("ggplot")
plt.rcParams.update(
    {
        "figure.dpi": 120,
        "figure.figsize": (12, 8),
        "axes.unicode_minus": False,
        "font.sans-serif": ["SimHei", "Arial Unicode MS"],
    }
)


# --- 快捷函数 ---
def dt_now():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def fplot(formula, x_range=(-5, 5), points=500):
    """快速绘制 y = f(x)"""
    x = np.linspace(*x_range, points)
    y = eval(formula.replace("=", ":").split(":")[-1], {"np": np, "x": x})
    plt.plot(x, y)
    plt.title(f"Plot: {formula}")
    plt.show()


# ============================================================
# 归元历
# ============================================================


class YuanCalendar:
    """
    冬至为岁首，30日为一月，年初余日记为0月。

    纪元：
        公元1年冬至为归元元年。

    历法：
        每年360个常规日。
        年初余日为5或6天。
        余日记为0月。

    天文算法：
        Meeus, Astronomical Algorithms, Chapter 27.
        纯 Python 实现，不依赖 Skyfield 或外部星历。

    时间系统：
        Meeus 计算得到 TT。
        使用 Espenak-Meeus ΔT 模型转换为 UTC。
        日期统一按 UTC 计算。
    """

    EPOCH_YEAR = 1

    # Meeus Table 27.C: 24 periodic terms
    _A = (
        485,
        203,
        199,
        182,
        156,
        136,
        77,
        74,
        70,
        58,
        52,
        50,
        45,
        44,
        29,
        18,
        17,
        16,
        14,
        12,
        12,
        12,
        9,
        8,
    )

    _B = (
        324.96,
        337.23,
        342.08,
        27.85,
        73.14,
        171.52,
        222.54,
        296.72,
        243.58,
        119.81,
        297.17,
        21.02,
        247.54,
        325.15,
        60.93,
        155.12,
        288.79,
        198.04,
        199.76,
        95.39,
        287.11,
        320.81,
        227.73,
        15.45,
    )

    _C = (
        1934.136,
        32964.467,
        20.186,
        445267.112,
        45036.886,
        22518.443,
        65928.934,
        3034.906,
        9037.513,
        33718.147,
        150.678,
        2281.226,
        29929.562,
        31555.956,
        4443.417,
        67555.328,
        4562.452,
        62894.029,
        31436.921,
        14577.848,
        31931.756,
        34777.259,
        1222.114,
        16859.074,
    )

    # --------------------------------------------------------
    # ΔT = TT - UT, in seconds
    # Espenak-Meeus polynomial approximation
    # --------------------------------------------------------

    @staticmethod
    def delta_t(year):
        """
        估算 ΔT（秒）。

        year 使用十进制年份。
        适用范围约为公元前1999年至公元3000年。
        """

        y = year

        if y < -500:
            u = (y - 1820) / 100
            return -20 + 32 * u**2

        elif y < 500:
            u = y / 100
            return (
                10583.6
                - 1014.41 * u
                + 33.78311 * u**2
                - 5.952053 * u**3
                - 0.1798452 * u**4
                + 0.022174192 * u**5
                + 0.0090316521 * u**6
            )

        elif y < 1600:
            u = (y - 1000) / 100
            return (
                1574.2
                - 556.01 * u
                + 71.23472 * u**2
                + 0.319781 * u**3
                - 0.8503463 * u**4
                - 0.005050998 * u**5
                + 0.0083572073 * u**6
            )

        elif y < 1700:
            t = y - 1600
            return 120 - 0.9808 * t - 0.01532 * t**2 + t**3 / 7129

        elif y < 1800:
            t = y - 1700
            return (
                8.83
                + 0.1603 * t
                - 0.0059285 * t**2
                + 0.00013336 * t**3
                - t**4 / 1174000
            )

        elif y < 1860:
            t = y - 1800
            return (
                13.72
                - 0.332447 * t
                + 0.0068612 * t**2
                + 0.0041116 * t**3
                - 0.00037436 * t**4
                + 0.0000121272 * t**5
                - 0.0000001699 * t**6
                + 0.000000000875 * t**7
            )

        elif y < 1900:
            t = y - 1860
            return (
                7.62
                + 0.5737 * t
                - 0.251754 * t**2
                + 0.01680668 * t**3
                - 0.0004473624 * t**4
                + t**5 / 233174
            )

        elif y < 1920:
            t = y - 1900
            return (
                -2.79
                + 1.494119 * t
                - 0.0598939 * t**2
                + 0.0061966 * t**3
                - 0.000197 * t**4
            )

        elif y < 1941:
            t = y - 1920
            return 21.20 + 0.84493 * t - 0.076100 * t**2 + 0.0020936 * t**3

        elif y < 1961:
            t = y - 1950
            return 29.07 + 0.407 * t - t**2 / 233 + t**3 / 2547

        elif y < 1986:
            t = y - 1975
            return 45.45 + 1.067 * t - t**2 / 260 - t**3 / 718

        elif y < 2005:
            t = y - 2000
            return (
                63.86
                + 0.3345 * t
                - 0.060374 * t**2
                + 0.0017275 * t**3
                + 0.000651814 * t**4
                + 0.00002373599 * t**5
            )

        elif y < 2050:
            t = y - 2000
            return 62.92 + 0.32217 * t + 0.005589 * t**2

        elif y < 2150:
            u = (y - 1820) / 100
            return -20 + 32 * u**2 - 0.5628 * (2150 - y)

        else:
            u = (y - 1820) / 100
            return -20 + 32 * u**2

    # --------------------------------------------------------
    # Meeus Chapter 27: Winter Solstice
    # --------------------------------------------------------

    @classmethod
    @lru_cache(maxsize=None)
    def winter_solstice_time(cls, year):
        """
        计算指定年份冬至的 UTC 时刻。

        返回带 UTC 时区信息的 datetime。
        适用年份：公元1年至3000年。
        """

        if not 1 <= year <= 3000:
            raise ValueError("Meeus 算法支持范围：公元1年至3000年")

        # Step 1: Mean December solstice (JDE0)

        if year < 1000:
            # Table 27.A: -1000 to +1000
            y = year / 1000

            jde0 = 1721414.39987 + y * (
                365242.88257 + y * (-0.00769 + y * (-0.00933 - y * 0.00006))
            )

        else:
            # Table 27.B: +1000 to +3000
            y = (year - 2000) / 1000

            jde0 = 2451900.05952 + y * (
                365242.74049 + y * (-0.06223 + y * (-0.00823 + y * 0.00032))
            )

        # Step 2: Periodic corrections

        T = (jde0 - 2451545.0) / 36525

        W = math.radians(35999.373 * T - 2.47)

        delta_lambda = 1 + 0.0334 * math.cos(W) + 0.0007 * math.cos(2 * W)

        S = sum(
            a * math.cos(math.radians(b + c * T))
            for a, b, c in zip(cls._A, cls._B, cls._C)
        )

        jde = jde0 + 0.00001 * S / delta_lambda

        # Step 3: TT -> UTC

        # December midpoint decimal year
        decimal_year = year + 11.5 / 12

        delta_t = cls.delta_t(decimal_year)

        # JD 2451545.0 = 2000-01-01 12:00 TT
        epoch = datetime.datetime(
            2000,
            1,
            1,
            12,
            tzinfo=datetime.timezone.utc,
        )

        utc = epoch + datetime.timedelta(
            days=jde - 2451545.0,
            seconds=-delta_t,
        )

        return utc

    @classmethod
    def winter_solstice(cls, year):
        """返回指定年份冬至的 UTC 公历日期。"""

        return cls.winter_solstice_time(year).date()

    # --------------------------------------------------------
    # Gregorian continuous day
    # --------------------------------------------------------

    @staticmethod
    def civil_day(year, month, day):
        """计算前推格里历连续日序，支持公元前。"""

        year -= month <= 2
        era = year // 400
        yoe = year - era * 400

        doy = (153 * (month + (-3 if month > 2 else 9)) + 2) // 5 + day - 1

        doe = yoe * 365 + yoe // 4 - yoe // 100 + doy

        return era * 146097 + doe

    # --------------------------------------------------------
    # Calendar conversion
    # --------------------------------------------------------

    def convert(self, year, month, day):
        """将公历日期转换为归元历。"""

        date = datetime.date(year, month, day)

        return self._convert(date)

    def today(self, now=None):
        """计算当前 UTC 日期对应的归元历日期。"""

        if now is None:
            now = datetime.datetime.now(datetime.timezone.utc)

        if isinstance(now, datetime.datetime):
            if now.tzinfo is None:
                # Naive datetime: interpret as local system time
                now = now.astimezone()

            now = now.astimezone(datetime.timezone.utc).date()

        elif not isinstance(now, datetime.date):
            raise TypeError("now 必须是 datetime.date 或 datetime.datetime")

        return self._convert(now)

    def _convert(self, now):
        """归元历核心转换。"""

        y = now.year

        # Determine the most recent winter solstice
        start_year = y if now >= self.winter_solstice(y) else y - 1

        # Consecutive winter solstices
        s0 = self.winter_solstice(start_year)
        s1 = self.winter_solstice(start_year + 1)

        # Gregorian continuous days
        start_day = self.civil_day(s0.year, s0.month, s0.day)

        end_day = self.civil_day(s1.year, s1.month, s1.day)

        today_day = self.civil_day(now.year, now.month, now.day)

        # Year length
        year_days = end_day - start_day
        extra_days = year_days - 360

        if extra_days not in (5, 6):
            raise ValueError(f"异常历年长度: {year_days}")

        # Day index within the Yuan year
        days = today_day - start_day

        if not 0 <= days < year_days:
            raise ValueError("日期超出本历年范围")

        # Yuan year: 1 CE winter solstice = Yuan year 1
        yuan_year = start_year - self.EPOCH_YEAR + 1

        # Extra days at the beginning of the year
        if days < extra_days:
            month, day = 0, days + 1

        # Regular 30-day months
        else:
            month, day = divmod(days - extra_days, 30)
            month, day = month + 1, day + 1

        return yuan_year, month, day, days


# --- 初始化打印 ---
def _welcome():
    print(f"🚀 Environment Loaded | {dt_now()}")
    print(f"📦 Backends: Torch {torch.__version__}")


if __name__ == "__main__":
    _welcome()
