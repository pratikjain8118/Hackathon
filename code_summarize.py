import os
import openai
from dotenv import load_dotenv
from langchain.chat_models import ChatOpenAI
from langchain.schema import (
    AIMessage,
    HumanMessage,
    SystemMessage
)
import tiktoken
from langchain.prompts import ChatPromptTemplate
from langchain.llms import OpenAI
import time
load_dotenv()


def num_tokens_from_string(string: str, encoding_name: str="gpt-3.5-turbo") -> int:
    """Returns the number of tokens in a text string."""
    encoding = tiktoken.encoding_for_model(encoding_name)
    num_tokens = len(encoding.encode(string))
    return num_tokens


def read_files(directory):
    filesInput = {}
    for root, dirs, files in os.walk(directory):
        # print(files)
        for file in files:
            file_path = os.path.join(root, file)
            # print(file_path.find('\.'))
            if(file_path.endswith('.cbl')) and file_path.find('\.') == -1:
                with open(file_path, 'r', errors="ignore") as f:
                    # print(file_path)
                    content = f.read()
                    num_tokens = num_tokens_from_string(content)
                    # print(num_tokens)
                    if(num_tokens>3500):
                        temp = 0
                        filesInput[f'{file_path}_split']={}
                # test = "";
                        while temp< num_tokens:
                            test=(content[temp:temp+3500])
                            filesInput[f'{file_path}_split'][f'{file_path}_{temp}']=test
                            temp += 3500
                    # Process the content of the file as needed
                    # print(file_path)
                    else:
                        filesInput[file_path]=content
                # print(content)
    return filesInput

def summarizeLargeCode(chat,filesInput):
    template_string_split = """You are a tech assistant, a huge code is splitted into chunks and you are given the summary of the previous chunk \
        of the code(it will be empty if the current split is start of the code) and the next part of the code with the path of file as key and it's content as value\
        you need to understand the current chunk of code based on previous summary and current chunk and provide the summary for the whole code until now \
            previous_code_summary={summary}
            current_code={filesInput}"""
    prompt_template_split = ChatPromptTemplate.from_template(template_string_split)
    
    fullSummary = ''
    summary = ''
    for item in filesInput.items():
        # print(item)
        code_prompt = prompt_template_split.format_messages(
                        summary=summary,filesInput=item)
        # print(code_prompt)
        response = chat(code_prompt)
        summary =response.content
        # print(summary)
        fullSummary+= summary
        # print('\nNext File:\n')
        time.sleep(20)


    # print(fullSummary)


    template_string_summary = """You are a tech assistant, a huge code is splitted into chunks and you are given the summary of each chunk
        of the code you need to understand the summary of each chunk of code provide the output for the whole code in provide the output in follwing format:
                'Explanation': A simple easy to understand exlpaination of the complete functionality of the code in plain english for a business user in bullet points(limit it to maximum 5 bullet points),
                'Business Rules':Some business rules extracted from the code,
                'Test Case': Test Cases(both positive and negative) in the form of a table with the columns- 'Test Case ID','Test Scenario','Test Case','Pre-Condition','Test Steps','Test Data','Expected Result'
            code_summary={fullSummary}
            """
    prompt_template_summary = ChatPromptTemplate.from_template(template_string_summary)
    code_prompt = prompt_template_summary.format_messages(
                        fullSummary=fullSummary)
        # print(code_prompt)
    response = chat(code_prompt)
    summary =response.content
    return (summary)

if __name__ == "__main__":
    print("Here")
    chat = ChatOpenAI(temperature=0.0)
    template_string = """You are a  tech assistant, you are give a item seperated by ''' with the path of file as key and it's content as value,you have to \
            understand the file and depending whether the file contains code or not you need to output one of two ways \
            1.For the code explain each line of code in brief and also provide the output in follwing format:
                'Explanation': A simple easy to understand exlpaination of the complete functionality of the code in plain english for a business user in bullet points(limit it to maximum 5 bullet points),
                'Business Rules':Some business rules extracted from the code,
                'Test Case': Test Cases(both positive and negative) in the form of a table with the columns- 'Test Case ID','Test Scenario','Test Case','Pre-Condition','Test Steps','Test Data','Expected Result'
            2.For other files tell their use is in short
            file_dictionary='''{filesInput}'''"""
    prompt_template = ChatPromptTemplate.from_template(template_string)
    # directory_path = './folder4/Cobol/OpenCobol'
    directory_path = './folder7'
    filesInput=read_files(directory_path)
    # print(read_files(directory_path));
    # directory_path = './folder5/python-telegram-bot'
    
    for item in filesInput.items():
        print(item[0])
        summary=''
        if (str(item[0])).find('_split')!= -1:
            summary=summarizeLargeCode(chat,item[1])
        else:
            code_prompt = prompt_template.format_messages(
                            filesInput=item)
            # print(code_prompt)
            response = chat(code_prompt)
            summary=(response.content)
            
        # print(item[0].split('\\')[-1])
        fileName  = item[0].split('\\')[-1]
        # fileName = fileName.split('.')[0]
        fileName = fileName.split('_split')[0]
        with open(f"output/output_test.txt", 'w') as f:
            f.write('\n')
            f.write('\n')
            f.write(fileName)
            f.write('\n')
            f.write('\n')
            f.write(summary)
        #     # f.write("Test")
        # print(response.content)
        # print('\nNext File:\n')
        time.sleep(20)