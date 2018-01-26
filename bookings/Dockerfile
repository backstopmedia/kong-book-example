FROM python:alpine

WORKDIR /usr/src/app

COPY . .
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python"]

CMD ["app.py"]
