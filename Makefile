install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

format:	
	black *.py 

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	
	cml comment create --publish report.md
		
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin $(BRANCH)

hf-login: 
	pip install -U "huggingface_hub[cli]"
	huggingface-cli login --token $(HF)

push-hub:
	git remote add origin https://huggingface.co/spaces/avivsimontahar/drug_classification
	git add ./App/app.py
	git config --global user.email "simontahar@proton.me"
	git config --global user.name "avivsimontahar"
	git commit -m "Add application file"
	git push
	huggingface-cli upload avivsimontahar/drug_classification ./App --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload avivsimontahar/drug_classification ./Model /Model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload avivsimontahar/drug_classification ./Results /Metrics --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub

all: install format train eval update-branch deploy