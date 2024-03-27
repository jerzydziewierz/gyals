sudo apt install -y screen
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
# need to enter new bash at this point
bash
conda create -n yals python=3 -y
conda activate yals
python -m pip install -U paho-mqtt


# this is only needed if you need the notebook development environment.
# this is NOT needed if you just want to run the logsaver -- it is intentionally light on dependencies.
# python -m pip install -U git+https://github.com/jerzydziewierz/notebookinit.git


# start the logsaver in screen:
./start.sh


