# 🦊 Firefox Cloud Browser

<div align="center">

![Firefox](https://img.shields.io/badge/Firefox-FF7139?style=for-the-badge&logo=Firefox-Browser&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu_22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![GitHub Codespaces](https://img.shields.io/badge/GitHub_Codespaces-181717?style=for-the-badge&logo=github&logoColor=white)

**تولید شده توسط امیرمهدی محمدزاده**

*اجرای مرورگر کامل Firefox مستقیماً در GitHub — بدون نصب، بدون محدودیت*

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/YOUR_USERNAME/YOUR_REPO)

</div>

---

## ✨ ویژگی‌ها

- ✅ Firefox کامل در مرورگر شما
- ✅ بدون محدودیت iframe
- ✅ دسترسی به یوتیوب، نتفلیکس و هر سایتی
- ✅ رابط کاربری فارسی شخصی‌سازی شده
- ✅ راه‌اندازی خودکار با یک کلیک
- ✅ نظارت و راه‌اندازی مجدد خودکار سرویس‌ها

---

## 🚀 نحوه استفاده

### گام ۱
روی دکمه بالا کلیک کنید یا:
- به صفحه مخزن بروید
- روی **Code** سبز کلیک کنید
- تب **Codespaces** را بزنید
- **Create codespace on main** را انتخاب کنید

### گام ۲
صبر کنید (حدود ۳-۵ دقیقه)

### گام ۳
گیتهاب پورت ۶۰۸۰ را **خودکار** در مرورگرتان باز می‌کند.
Firefox آماده است! 🎉

---

## 🔧 مشکل‌یابی

```bash
# مشاهده لاگ‌ها
cat /tmp/browser-logs/firefox.log
cat /tmp/browser-logs/websockify.log
cat /tmp/browser-logs/x11vnc.log

# راه‌اندازی مجدد
bash /workspace/start-browser.sh

# بررسی پردازش‌ها
ps aux | grep -E "firefox|x11vnc|websockify|Xvfb"
