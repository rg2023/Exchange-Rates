from vertexai.language_models import ChatModel
import vertexai

def ask_vertex_ai(question: str) -> str:
    vertexai.init(project="sandbox-lz-rachelge", location="me-west1")
    chat_model = ChatModel.from_pretrained("chat-bison@001")
    chat = chat_model.start_chat()
    response = chat.send_message(question)
    return response.text
