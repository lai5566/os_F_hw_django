# os_F_hw_django
操作系統，期末課堂作業，
#安裝 Python

### 建立虛擬環境
虛擬環境中運行 Django 專案。使用以下命令建立並啟動虛擬環境：

```bash
pip install venv
```
```bash
python -m venv myenv
```
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


```bash
cd /myweb/myweb
```
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
python manage.py runserver
```





