FROM nvcr.io/nvidia/pytorch:24.07-py3

EXPOSE 28000

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && apt update && apt install python3-tk -y

RUN mkdir /app

WORKDIR /app
RUN git clone --recurse-submodules https://github.com/Akegarasu/lora-scripts

WORKDIR /app/lora-scripts

# 设置 Python pip 软件包国内镜像代理
# RUN pip config set global.index-url 'https://pypi.tuna.tsinghua.edu.cn/simple' && \
#     pip config set install.trusted-host 'pypi.tuna.tsinghua.edu.cn'

# 初次安装依赖
RUN pip install xformers==0.0.27.post2 --no-deps && pip install -r requirements.txt && rm -rf ~/.cache/pip/*

# 更新 训练程序 stable 版本依赖
RUN git config --global http.sslVerify false
RUN rm -rf /app/lora-scripts/scripts/stable && cd /app/lora-scripts/scripts/ && git clone --recurse-submodules https://github.com/kohya-ss/sd-scripts.git stable
WORKDIR /app/lora-scripts/scripts/stable
RUN pip install -r requirements.txt && rm -rf ~/.cache/pip/*

# 更新 训练程序 dev 版本依赖
# WORKDIR /app/lora-scripts/scripts/dev
# RUN pip install -r requirements.txt && rm -rf ~/.cache/pip/*

WORKDIR /app/lora-scripts

# 修正运行报错以及底包缺失的依赖
# ref
# - https://soulteary.com/2024/01/07/fix-opencv-dependency-errors-opencv-fixer.html
# - https://blog.csdn.net/qq_50195602/article/details/124188467
RUN pip install opencv-fixer==0.2.5 && python -c "from opencv_fixer import AutoFix; AutoFix()" \
    pip install opencv-python-headless && apt install ffmpeg libsm6 libxext6 libgl1 -y && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ~/.cache/pip/*

RUN pip install onnxruntime onnxruntime-gpu accelerate==0.33.0 lion-pytorch==0.1.2 prodigyopt==1.1.2 safetensors==0.4.4 && rm -rf ~/.cache/pip/*

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
RUN pip config set install.trusted-host mirrors.aliyun.com

CMD ["python", "gui.py", "--listen"]
