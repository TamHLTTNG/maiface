FROM python:3.10

# https://pytorch.org/get-started/locally/
RUN pip3 install --upgrade pip
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
RUN pip3 install faiss-cpu
RUN pip3 install facenet-pytorch
RUN pip3 install aiofiles Jinja2
RUN pip3 install pillow
RUN pip3 install fastapi python-multipart
RUN pip3 install uvicorn[standard] Gunicorn
RUN pip3 install redis
RUN pip3 install six

RUN mkdir /var/www/
WORKDIR /var/www
RUN git clone https://github.com/masayay/maiface.git
RUN mv maiface/conf_linux_sample.py maiface/conf.py

RUN mkdir /etc/gunicorn
RUN mv maiface/maiface_config.py /etc/gunicorn/maiface_config.py

RUN mkdir /var/log/gunicorn
RUN mkdir /var/lib/maiface
RUN mkdir /var/lib/maiface/cache
RUN mkdir /var/lib/maiface/embeddings

RUN useradd -U -m -s /usr/sbin/nologin gunicorn
RUN chown gunicorn:gunicorn /var/log/gunicorn
RUN chown -R gunicorn:gunicorn /var/www/maiface
RUN chown -R gunicorn:gunicorn /var/lib/maiface
RUN chown -R gunicorn:gunicorn /etc/gunicorn

RUN mv maiface/systemd_sample.txt /etc/systemd/system/maiface.service

## フォルダ作成＆必要に応じてconf修正
RUN mkdir -p /var/www/maiface/{embeddings,cache}

# アプリケーション起動
WORKDIR /var/www/maiface
CMD ["uvicorn", "--host", "0.0.0.0", "--port", "8000", "face_api:app"]

# systemctl daemon-reload
# systemctl start maiface

# apt install nginx
# cp maiface/nginx_sample.txt /etc/nginx/sites-available/maiface
# rm -f /etc/nginx/sites-enabled/default
# ln -s /etc/nginx/sites-available/maiface /etc/nginx/sites-enabled/maiface
# systemctl start nginx

