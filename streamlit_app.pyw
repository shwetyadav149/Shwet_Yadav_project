{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "8c613603-31d2-410c-bea2-2869f00699f8",
   "metadata": {},
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "2026-04-17 01:54:42.040 WARNING streamlit.runtime.scriptrunner_utils.script_run_context: Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.467 \n",
      "  \u001b[33m\u001b[1mWarning:\u001b[0m to view this Streamlit app on a browser, run it with the following\n",
      "  command:\n",
      "\n",
      "    streamlit run C:\\Users\\shwet\\AppData\\Roaming\\Python\\Python313\\site-packages\\ipykernel_launcher.py [ARGUMENTS]\n",
      "2026-04-17 01:54:42.470 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.472 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.476 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.478 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.480 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.482 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.486 Session state does not function when running a script without `streamlit run`\n",
      "2026-04-17 01:54:42.489 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.490 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.492 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.495 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.497 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.499 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.501 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.504 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.506 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.508 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.511 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.513 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.515 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.517 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.519 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.522 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.524 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.528 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.530 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.532 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.534 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.536 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n",
      "2026-04-17 01:54:42.539 Thread 'MainThread': missing ScriptRunContext! This warning can be ignored when running in bare mode.\n"
     ]
    }
   ],
   "source": [
    "import os\n",
    "import requests\n",
    "import streamlit as st\n",
    "from dotenv import load_dotenv\n",
    "from langchain_groq import ChatGroq\n",
    "\n",
    "load_dotenv()\n",
    "\n",
    "st.title(\"📰 AI News Reader\")\n",
    "\n",
    "name = st.text_input(\"Enter your name\")\n",
    "email = st.text_input(\"Enter your email\")\n",
    "interest = st.text_input(\"Enter your interest\")\n",
    "\n",
    "if st.button(\"Get News\"):\n",
    "\n",
    "    url = f\"https://newsapi.org/v2/everything?q={interest}&apiKey={os.getenv('NEWS_API_KEY')}\"\n",
    "    response = requests.get(url).json()\n",
    "    articles = response.get(\"articles\", [])[:5]\n",
    "\n",
    "    llm = ChatGroq(\n",
    "        groq_api_key=os.getenv(\"GROQ_API_KEY\"),\n",
    "        model=\"llama-3.1-8b-instant\"\n",
    "    )\n",
    "\n",
    "    for article in articles:\n",
    "        st.subheader(article.get(\"title\", \"No title\"))\n",
    "\n",
    "        text = article.get(\"title\", \"\") + str(article.get(\"description\", \"\"))\n",
    "\n",
    "        prompt = f\"Summarize this news: {text}\"\n",
    "\n",
    "        summary = llm.invoke(prompt).content\n",
    "        st.write(summary)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "0fbdacb1-bd11-457c-9350-a370a17bb37f",
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.13.9"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
