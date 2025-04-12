FROM pytorch/pytorch:2.4.1-cuda12.4-cudnn9-devel

EXPOSE 28000

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && apt update && apt install python3-tk -y

RUN mkdir /app && apt update && apt install -y git git-lfs wget net-tools tree curl apt-utils iputils-ping

WORKDIR /app
RUN git clone --recurse-submodules https://github.com/Akegarasu/lora-scripts

WORKDIR /app/lora-scripts
RUN pip install -U pip
RUN pip install torch==2.4.1+cu124 torchvision==0.19.1+cu124 xformers --extra-index-url https://download.pytorch.org/whl/cu124
RUN pip install -U setuptools wheel && pip install --upgrade -r requirements.txt
RUN apt-get install -y libgl1-mesa-glx

CMD ["python", "gui.py", "--listen"]
