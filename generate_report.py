import os
import glob
import sys
import re

def get_tools():
    tools = [
        "Subfinder",
        "httpx",
        "Nuclei",
        "NMAP",
        "WafW00f",
        "Dalfox",
        "AutoSSRF",
        "OpenRedirectX",
        "SQLmap",
        "Arjun",
        "DroopeScan",
        "jSQL",
        "wFuzz",
        # Add more tools here as needed
    ]
    return tools

def generate_html_header(title):
    html = f"<!DOCTYPE html>\n<html lang='en'>\n<head>\n  <meta charset='UTF-8'>\n  <meta name='viewport' content='width=device-width, initial-scale=1.0'>\n  <title>{title}</title>\n  <style>\n    table {{ border-collapse: collapse; width: 100%; }}\n    th, td {{ border: 1px solid black; padding: 8px; text-align: left; }}\n    th {{ background-color: #f2f2f2; }}\n  </style>\n</head>\n<body>\n  <h1>{title}</h1>"
    return html

def generate_html_footer():
    html = "</body>\n</html>"
    return html

def generate_tool_table_header(tool_name):
    html = f"  <h2>{tool_name}</h2>\n  <table>\n    <tr><th>File</th><th>Results</th></tr>"
    return html

def generate_tool_table_row(file_name, finding):
    html = f"    <tr><td>{file_name}</td><td>{finding}</td></tr>\n"
    return html

def generate_finding_table_header(finding_title):
    html = f"  <h3>{finding_title}</h3>\n  <table>\n    <tr><th>Tool</th><th>Description</th><th>Proof of Concept</th></tr>"
    return html

def generate_finding_table_row(tool_name, description, proof_of_concept):
    html = f"    <tr><td>{tool_name}</td><td>{description}</td><td>{proof_of_concept}</td></tr>\n"
    return html

def generate_report(project_folder, report_title):
    os.makedirs("report", exist_ok=True)

    html_header = generate_html_header(report_title)
    html_footer = generate_html_footer()

    tools = get_tools()

    html_content = ""

    for domain_folder in glob.glob(os.path.join(project_folder, "*/")):
        domain_name = os.path.basename(domain_folder)
        html_content += f"  <h2>Domain: {domain_name}</h2>\n"

        for tool in tools:
            tool_folder = os.path.join(domain_folder, tool.lower())
            if os.path.exists(tool_folder):
                html_content += generate_tool_table_header(tool)

                for file_name in glob.glob(os.path.join(tool_folder, "*.txt")):
                    file_name = os.path.basename(file_name)
                    html_content += generate_tool_table_row(file_name, "TODO: Add finding description")

                html_content += "</table>\n"

                findings = []

                for file_name in glob.glob(os.path.join(tool_folder, "*.txt")):
                    file_path = os.path.join(tool_folder, file_name)
                    with open(file_path, "r") as findings_file:
                        for line in findings_file:
                            findings.append(line.strip())

                for finding in findings:
                    if finding not in html_content:
                        tool_name = tool
                        description = "TODO: Add finding description"
                        proof_of_concept = "TODO: Add proof of concept link or image"
                        html_content += generate_finding_table_header(finding)
                        html_content += generate_finding_table_row(tool_name, description, proof_of_concept)

        html_content += "</table>\n"

    html_content += html_footer

    with open(os.path.join("report", "index.html"), "w") as report_file:
        report_file.write(html_header + html_content + html_footer)

    print("Report generated: report/index.html")

if __name__ == "__main__":
    project_folder = sys.argv[1]
    report_title = "Reconnaissance Report"
    generate_report(project_folder, report_title)