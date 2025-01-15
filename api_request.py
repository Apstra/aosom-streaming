#!/usr/bin/env python
import json
import os
from string import Template
import sys
from time import sleep
from typing import Optional, Dict

try:
    import click
except ImportError:
    print(
        "Click module not found - "
        "please install using 'pip install click'"
    )
    sys.exit(1)
try:
    from dotenv import load_dotenv
except ImportError:
    print(
        "Dotenv module not found - "
        "please install using 'pip install python-dotenv'"
    )
    sys.exit(1)
try:
    import requests
    from requests.auth import HTTPBasicAuth
except ImportError:
    print(
        "Requests module not found - "
        "please install using 'pip install requests'"
    )
    sys.exit(1)


USERNAME = os.getenv("GRAFANA_LOGIN", "admin")
PASSWORD = os.getenv("GRAFANA_PASSWORD", "aos-aos")
RETRIES = int(os.getenv("GRAFANA_API_RETRIES", "5"))

AUTH = HTTPBasicAuth(USERNAME, PASSWORD)
HEADERS = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "charset": "UTF-8",
}

URL_BASE = "http://localhost:3000"


def load_template(name: str, local_ip: str) -> Dict:
    with open(f"dashboards/{name}.json", "r") as f:
        template = Template(f.read())
    return json.loads(template.safe_substitute(local_ip=local_ip))


@click.command()
@click.option("--url")
@click.option("--method", default="GET")
@click.option("--template", required=False)
def request(
    url: str, method: Optional[str] = "GET", template: Optional[str] = None
) -> Dict:
    local_ip = os.getenv("LOCAL_IP")
    assert local_ip, "LOCAL_IP environment variable not set"
    data = load_template(template, local_ip=local_ip) if template else {}
    for i in range(RETRIES):
        try:
            response = requests.request(
                method.upper(),
                f"{URL_BASE}{url}",
                headers=HEADERS,
                auth=AUTH,
                data=json.dumps(data),
            )

            response.raise_for_status()
            result = response.json()
            print(json.dumps(result, indent=2))

            return result
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
            if i < RETRIES - 1:
                print(f"Retrying {i+1}/{RETRIES}")
                sleep(2)
                continue
            else:
                print(f"Failed after {RETRIES} retries")
                sys.exit(1)


if __name__ == "__main__":
    assert os.path.exists(
        "variables.env"
    ), "Variables file variables.env not found - exiting"
    load_dotenv("variables.env")
    request()
