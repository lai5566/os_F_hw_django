# os_F_hw_django
作業系統，期末課堂作業，
安裝 Python
<br>
<br>
[notion](https://glow-panama-957.notion.site/51-e1aabcfa3590443f90ff249f3fa057ed?pvs=4)
<br>
## 修改進度
### ✅ 血壓輸入頁面 主題 蒐縮壓 舒張壓 
### ✅ 血壓歷史頁面 用哪個帳號輸入的 主題 蒐縮壓 舒張壓 時間戳
### 🚧 用網頁註冊的使用者無法登入
無法登入問題用需要用superuser到/admin，手動開啟權限
### 建立虛擬環境
虛擬環境中運行 Django 專案。使用以下命令建立並啟動虛擬環境：

## 使用
安裝虛擬環境
```bash
pip install venv
```
建立虛擬環境
```bash
python3 -m venv myenv
```
進入虛擬環境
```bash
source myenv/bin/activate  # 對於 Windows 系統，使用 `env\Scripts\activate`
```
安裝 Django
在虛擬環境啟動後，使用 pip 安裝 Django：

```bash
pip install django
```


### 遷移數據庫
數據庫的遷移：

進入專案資料夾
```bash
cd /myweb/myweb
```
開始遷移
```bash
python manage.py makemigrations
```

```bash
python manage.py migrate
```
### 建立超級使用者


```bash
python manage.py createsuperuser
```
### 啟動
```python
python manage.py runserver 0.0.0.0:8000
```





