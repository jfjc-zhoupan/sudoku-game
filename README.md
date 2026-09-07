# Sudoku

Python Sudoku with a desktop window (`sudoku.py`) and a website (`app.py`).

## Play on your computer

Desktop:

```bash
python sudoku.py
```

Website (local):

```bash
python -m pip install -r requirements.txt
python app.py
```

Then open http://127.0.0.1:5000

## Deploy on Ubuntu

Copy the project to the server, then install Python, nginx, and a virtualenv. Gunicorn serves the Flask app on localhost; nginx publishes it on port 80.

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip nginx

sudo mkdir -p /var/www/sudoku
sudo rsync -a --exclude venv --exclude .git ./ /var/www/sudoku/
sudo chown -R www-data:www-data /var/www/sudoku

cd /var/www/sudoku
sudo -u www-data python3 -m venv venv
sudo -u www-data ./venv/bin/pip install -r requirements.txt

sudo cp deploy/sudoku.service /etc/systemd/system/sudoku.service
sudo cp deploy/nginx.conf /etc/nginx/sites-available/sudoku
sudo ln -sf /etc/nginx/sites-available/sudoku /etc/nginx/sites-enabled/sudoku
sudo rm -f /etc/nginx/sites-enabled/default

sudo systemctl daemon-reload
sudo systemctl enable --now sudoku
sudo nginx -t
sudo systemctl reload nginx
```

Visit `http://YOUR_SERVER_IP`.

To use a domain, edit `deploy/nginx.conf` and set `server_name example.com;`, then copy it to nginx again and reload. For HTTPS, install certbot (`sudo apt install certbot python3-certbot-nginx` and `sudo certbot --nginx`).

## How to play

- Choose Easy, Medium, or Hard, then **New Game**.
- Click a cell and type `1`–`9`, or use the number buttons.
- **Erase** (or Backspace / Delete) clears a cell you filled.
- **Check** highlights cells that don't match the solution.
- **Hint** fills one empty cell.
