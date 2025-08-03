#!/usr/bin/env bash

CURRENT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
export MODEL_NAME=ChineseModernBert
export OUTPUT_DIR=$CURRENT_DIR/check_points
export BERT_DIR="/data/gongoubo/my_project/CLUE/baselines/models/ChineseModernBert"
export GLUE_DIR=$CURRENT_DIR/mrc_data # set your data dir
TASK_NAME="CMRC2018"

# download and unzip dataset
if [ ! -d $GLUE_DIR ]; then
  mkdir -p $GLUE_DIR
  echo "makedir $GLUE_DIR"
fi
cd $GLUE_DIR
if [ ! -d $TASK_NAME ]; then
  mkdir $TASK_NAME
  echo "makedir $GLUE_DIR/$TASK_NAME"
fi
cd $TASK_NAME
if [ ! -f "train.json" ] || [ ! -f "trial.json" ] || [ ! -f "dev.json" ] || [ ! -f "test.json" ]; then
  rm *
  wget https://storage.googleapis.com/cluebenchmark/tasks/cmrc2018_public.zip
  unzip cmrc2018_public.zip
  rm cmrc2018_public.zip
else
  echo "data exists"
fi
echo "Finish download dataset."


# make output dir
if [ ! -d $CURRENT_DIR/${TASK_NAME}_output ]; then
  mkdir -p $CURRENT_DIR/${TASK_NAME}_output
  echo "makedir $CURRENT_DIR/${TASK_NAME}_output"
fi

# run task
cd $CURRENT_DIR
python run_mrc.py \
  --gpu_ids="1,2,3,4,5,6" \
  --train_epochs=2 \
  --n_batch=32 \
  --lr=3e-5 \
  --warmup_rate=0.1 \
  --max_seq_length=512 \
  --task_name=$TASK_NAME \
  --bert_dir=$BERT_DIR \
  --train_dir=$GLUE_DIR/$TASK_NAME/train_features.json \
  --train_file=$GLUE_DIR/$TASK_NAME/train.json \
  --dev_dir1=$GLUE_DIR/$TASK_NAME/dev_examples.json \
  --dev_dir2=$GLUE_DIR/$TASK_NAME/dev_features.json \
  --dev_file=$GLUE_DIR/$TASK_NAME/dev.json \
  --checkpoint_dir=$OUTPUT_DIR/$TASK_NAME/$MODEL_NAME/

python test_mrc.py \
  --gpu_ids="0" \
  --n_batch=32 \
  --max_seq_length=512 \
  --task_name=$TASK_NAME \
  --bert_dir=$BERT_DIR \
  --checkpoint_dir=$OUTPUT_DIR/$TASK_NAME/$MODEL_NAME/ \
  --output_dir=$OUTPUT_DIR/$TASK_NAME/$MODEL_NAME/ \
  --test_dir1=$GLUE_DIR/$TASK_NAME/test_examples.json \
  --test_dir2=$GLUE_DIR/$TASK_NAME/test_features.json \
  --test_file=$GLUE_DIR/$TASK_NAME/test.json \




