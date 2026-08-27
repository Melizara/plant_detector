import io
from PIL import Image
from fastapi import FastAPI, File, UploadFile
import numpy as np
import tensorflow as tf

app = FastAPI(title="Plant Disease Detection API")

MODEL_PATH = "assets/plant_disease_model.tflite"
LABELS_PATH = "assets/plant_labels.txt"

with open(LABELS_PATH, "r", encoding="utf-8") as f:
  LABELS = [line.strip() for line in f.readlines() if line.strip()]

interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

input_shape = input_details[0]["shape"]
img_height, img_width = input_shape[1], input_shape[2]


@app.get("/")
def home():
  return {"status": "online", "message": "API Détecteur de plantes opérationnelle !"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):

  contents = await file.read()
  image = (
      Image.open(io.BytesIO(contents))
      .convert("RGB")
      .resize((img_width, img_height))
  )


  input_data = np.expand_dims(image, axis=0).astype(np.float32)


  interpreter.set_tensor(input_details[0]["index"], input_data)
  interpreter.invoke()
  output_data = interpreter.get_tensor(output_details[0]["index"])

  predicted_index = np.argmax(output_data[0])
  confidence = float(np.max(output_data[0]))

  predicted_label = (
      LABELS[predicted_index]
      if predicted_index < len(LABELS)
      else f"Classe {predicted_index}"
  )

  return {
      "prediction": predicted_label,
      "confidence": round(confidence, 4),
      "class_index": int(predicted_index),
  }
