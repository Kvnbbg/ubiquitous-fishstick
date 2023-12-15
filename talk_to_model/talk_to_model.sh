#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Authorship details
show_authorship_info() {
  echo "🤖 AI Chat Terminal Interface by Kevin Marville"
  echo "Author's GitHub: https://github.com/kvnbbg"
}

# Check for and install required commands
install_dependencies() {
  if ! command_exists "curl" || ! command_exists "jq"; then
    echo "Preparing the AI chat environment..."

    if command_exists "apt-get"; then
      sudo apt-get update
      sudo apt-get install -y curl jq
    elif command_exists "yum"; then
      sudo yum install -y curl jq
    elif command_exists "brew"; then
      brew install curl jq
    else
      echo "Unsupported package manager. Please install 'curl' and 'jq' manually."
      exit 1
    fi
  fi
}

# Set Hugging Face API token
set_api_token() {
  if [ -z "$HF_API_TOKEN" ]; then
    echo "Please provide your Hugging Face API token:"
    read -r HF_API_TOKEN
    export HF_API_TOKEN="$HF_API_TOKEN"
  fi
}

# Chat with AI function
chat_with_ai() {
  MODEL_ENDPOINT="https://api-inference.huggingface.co/models/t5-small"
  OS=$(uname -s)

  echo "Welcome to the AI Chat! Type 'exit' to end the conversation."

  while true; do
    read -p "You: " user_input

    if [[ "$user_input" == "exit" ]]; then
      echo "Exiting the conversation."
      break
    fi

    if [ -z "$HF_API_TOKEN" ]; then
      echo "Please set your Hugging Face API token."
      exit 1
    fi

    curl_response=$(curl -s -X POST \
      -H "Authorization: Bearer $HF_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"inputs": "'"$user_input"'"}' \
      "$MODEL_ENDPOINT")

    if [ $? -ne 0 ]; then
      echo "An error occurred. Please check your connection or try again later."
      exit 1
    fi

    bot_response=$(echo "$curl_response" | jq -r '.[0].generated_text')
    echo "Bot: $bot_response"
  done
}

# Main loop to restart conversation
while true; do
  show_authorship_info
  install_dependencies
  set_api_token
  chat_with_ai

  read -p "Do you want to start a new conversation? (yes/no): " choice
  if [[ "$choice" != "yes" ]]; then
    echo "Goodbye! Hope to chat again soon. 😊"
    break
  fi
done