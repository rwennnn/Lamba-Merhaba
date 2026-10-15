---
language:
- tr
tags:
- causal-lm
- turkish
- qwen
- instruction-tuning
license: apache-2.0
base_model:
- Qwen/Qwen3.5-0.8B-Base
---

# Lamba-750M

Lamba-750M is a compact Turkish language model. It is based on Qwen3.5 and trained specifically for Turkish instruction following.

## Intended Use
Designed for short Turkish tasks like classification, summarization, and text transformation. Not recommended for English prompts, long-form generation, math, or multi-step reasoning.


## Training
1. **Continual Pre-Training (CPT):** 10B Turkish tokens to adapt to Turkish grammar and vocabulary.
2. **Supervised Fine-Tuning (SFT):** Trained on question-answer instructions. Best eval loss: 0.9285 at ~18k steps.
3. **DPO:** Direct Preference Optimization for better alignment with human preferences.

## Capabilities
Small but effective for short Turkish tasks:
- Summarization
- Text classification (sentiment, topic)
- Text transformation (informal to formal, antonyms)
- Short, single-turn instructions

## Limitations
- Weak at math, logic, and multi-step reasoning. Do not use Chain-of-Thought, it increases hallucinations.
- Can hallucinate facts on knowledge-heavy topics.
- May repeat phrases in long generations.
- Text-only, no vision support.



## How to Use
```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_id = "cturan/Lamba-750M"

tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(
    model_id,
    device_map="auto",
    torch_dtype="bfloat16"
)

prompt = "Bu yorumun duygusunu tek kelimeyle belirt (olumlu/olumsuz): Ürün çok hızlı geldi, paketleme harikaydı ve tam beklediğim gibi çalışıyor."
inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

outputs = model.generate(**inputs, max_new_tokens=256, do_sample=False)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))