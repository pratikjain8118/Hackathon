import os
import openai
from dotenv import load_dotenv
from langchain.chat_models import ChatOpenAI
from langchain.schema import (
    AIMessage,
    HumanMessage,
    SystemMessage
)
from langchain import LLMChain
from langchain.chat_models import ChatOpenAI
from langchain.prompts.chat import (
    ChatPromptTemplate,
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate,
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

def businessRulesPrompt(fileInput):
    template_string = """I want you to act as a business user, you are given a COBOL program seperated by '''  \
            Your job is to understand the program and provide some business rules(Business rule is a criterion used in business operations to guide behaviour, shape judgements and make decisions) associated to it.\
            Avoid generating rules related to(do not show if these are not present in the program):\n \
            1.File opening\n 2.when the imput or output files are open and closed\n 3.when the programs stops running\n 4.recommendations(Recommendations like Program Should)\n 5.File closing\n\
            6.Do not include any redundant or repeated statements.\n \
            Try to Mininmize the number of rules as much as possible. \
            code='''{filesInput}'''"""
    prompt_template = ChatPromptTemplate.from_template(template_string)
    code_prompt = prompt_template.format_messages(
                            filesInput=fileInput)
    return code_prompt

def testCaseRulesPrompt(fileInput):
    template_string = """I want you to act as a Tester, you are given a COBOL program seperated by '''  \
            Your job is to understand the program and provide test cases(Think of all possbile scenarios and edge cases) associated to it.
            Output each testcase in the table with the following columns- 'Test Case ID','Test Scenario','Test Case','Pre-Condition','Test Steps','Test Data','Expected Result' 
            code='''{filesInput}'''"""
    prompt_template = ChatPromptTemplate.from_template(template_string)
    code_prompt = prompt_template.format_messages(
                            filesInput=fileInput)
    return code_prompt

def seqExplaination(code):
    with open('./sample.cbl', 'r', errors="ignore") as f:
        sample_program = f.read()

    template = "I want you to act as a business user, I am showing you a sample cobal program along with it's Explaination.\
    sample_program={sample_program}\
    explainantion=\
    1.This code is for an inventory management system, which helps businesses keep track of their products.\n \
    2.Users can enter item details like code, name, and quantity to add items to the inventory.\n \
    3.The system has a rule that limits the quantity of each item to 1000 units.\n \
    4.If someone tries to add more than 1000 units of an item, the system will show an error message.\n \
    5.The code also displays the current inventory, listing the item codes, names, and quantities that have been added.\n \
    I want you to generate similar explainantion for the program I will send to a non technical user in simple english in maximum 5 points, "
    system_message_prompt = SystemMessagePromptTemplate.from_template(template)
    human_template = "{code}"
    human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)

    chat_prompt = ChatPromptTemplate.from_messages([system_message_prompt, human_message_prompt])

    # chat_prompt.format_messages(sample_program=sample_program, code=code)
    chat = ChatOpenAI(temperature=0)
    chain = LLMChain(llm=chat, prompt=chat_prompt)
    response = chain.run(sample_program=sample_program, code=code)
    print(response)

def seqTest(code):
    with open('./sample.cbl', 'r', errors="ignore") as f:
        sample_program = f.read()

    template = "I want you to act as a business user, I am showing you a sample cobal program along with it's Business rules.\
    sample_program={sample_program}\
    business_rules=\
    1.The item quantity should not exceed the inventory limit, which is set to 1000 in this case.\n \
    2.If the user tries to add an item with a quantity exceeding the limit, an error message is displayed.\n \
    3.Otherwise, the item is added to the inventory, and the current inventory is displayed at the end.\n \
    Avoid generating rules related to:\n \
    1.File opening\n \
    2.when the input or output files are open and closed\n \
    3.when the programs stops running\n \
    4.recommendations(Recommendations like Program Should)\n \
    5.File closing\n \
    6.Do not include any redundant or repeated statements.\n \
    I want you to generate business rules in plain and simple language similar to above rules keeping in mind the rules to avoid for the program I will send.Genrate only 5 business rules"
    system_message_prompt = SystemMessagePromptTemplate.from_template(template)
    human_template = "{code}"
    human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)

    chat_prompt = ChatPromptTemplate.from_messages([system_message_prompt, human_message_prompt])

    # chat_prompt.format_messages(sample_program=sample_program, code=code)
    chat = ChatOpenAI(temperature=0)
    chain = LLMChain(llm=chat, prompt=chat_prompt)
    response = chain.run(sample_program=sample_program, code=code)
    print(response)


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
    for item in filesInput.items():
        seqTest(item[1])
        response = chat(businessRulesPrompt(item[1]))
        # print('\n\n')
        # print(response.content)
        # seqExplaination(item[1])
    # print(read_files(directory_path));
    # directory_path = './folder5/python-telegram-bot'
    
    # for item in filesInput.items():
    #     print(item[0])
    #     summary=''
    #     if (str(item[0])).find('_split')!= -1:
    #         summary=summarizeLargeCode(chat,item[1])
    #     else:
    #         code_prompt = prompt_template.format_messages(
    #                         filesInput=item)
    #         # print(code_prompt)
    #         # response = chat(code_prompt)
    #         # summary=(response.content)
    #         summary+='Business Rules:\n'
    #         response = chat(businessRulesPrompt(item[1]))
    #         summary+=(response.content)
    #         summary+='\n\nTest Cases:\n'
    #         response = chat(testCaseRulesPrompt(item[1]))
    #         summary+=(response.content)
            
    #     # print(item[0].split('\\')[-1])
    #     fileName  = item[0].split('\\')[-1]
    #     # fileName = fileName.split('.')[0]
    #     fileName = fileName.split('_split')[0]
    #     with open(f"output/output_test.txt", 'a') as f:
    #         f.write('\n')
    #         f.write('\n')
    #         f.write(fileName)
    #         f.write('\n')
    #         f.write('\n')
    #         f.write(summary)
    #     #     # f.write("Test")
    #     # print(response.content)
    #     # print('\nNext File:\n')
    #     time.sleep(60)