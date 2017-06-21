FROM binded/ci:1.0.0

RUN apt-get update -y \
  && apt-get install -y \
    python3 \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
