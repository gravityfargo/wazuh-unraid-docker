"""

"""

import bcrypt, re, yaml, requests, subprocess


def download_file(url, filename):
    """Download file from a specified URL and save it locally"""
    response = requests.get(url)
    if response.status_code == 200:
        with open(filename, "wb") as f:
            f.write(response.content)
        print(f"Downloaded {filename}")
        return True
    else:
        print(f"Failed to download {filename}")
        return False


def run_script(script, args):
    """Run script with specified arguments"""
    subprocess.run([script] + args, text=True, capture_output=True)


def hash_password(password):
    """Generate a salt and hash the password"""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode("utf-8"), salt)
    return hashed.decode("utf-8")


def main():
    print("pasword_hasher.py: Generating hashed passwords for stock Wazuh users...")
    generated_passwords_file = "wazuh-passwords.txt"
    script_filename = "wazuh-passwords-tool.sh"
    script_url = "https://packages.wazuh.com/4.8/wazuh-passwords-tool.sh"

    internal_users_file = "internal_users.yml"
    internal_users_url = "https://raw.githubusercontent.com/wazuh/wazuh-docker/v4.8.0/build-docker-images/wazuh-indexer/config/internal_users.yml"
    internal_users = {}
    api_users = {}

    if download_file(script_url, script_filename):
        run_script(
            "./" + script_filename, ["--generate-file", generated_passwords_file]
        )

    if download_file(internal_users_url, internal_users_file):
        with open(internal_users_file, "r") as file:
            internal_users = yaml.safe_load(file)

    with open(generated_passwords_file, "r") as file:
        lines = file.readlines()
        user = ""
        strpass = ""
        strhash = ""
        comment = ""
        print1 = 0
        print("Generated passwords for internal users:")
        print("====================================")
        for line in lines:
            match = re.match(r"^\s*indexer_username:\s*'([^']+)'", line)
            if match:
                user = match.group(1)

            if line.startswith("#"):
                comment = line[2:].strip()

            match = re.match(r"^\s*indexer_password:\s*'([^']+)'", line)
            if match:
                strpass = match.group(1)
                strhash = hash_password(strpass)

                if internal_users.get(user) is not None:
                    print(f" {user}: {strpass}")
                    internal_users[user]["hash"] = strhash
                    internal_users[user]["description"] = comment

            match = re.match(r"^\s*api_username:\s*'([^']+)'", line)
            if match:
                api_user = match.group(1)
                api_users[api_user] = ""

            match = re.match(r"^\s*api_password:\s*'([^']+)'", line)
            if match:
                api_pass = match.group(1)
                api_users[api_user] = api_pass
                if not print1:
                    print(f" API credentials:")
                    print1 = 1
                    
                print(f" {api_user}: {api_pass}")
        print("====================================")

    with open(internal_users_file, "w") as file:
        internal_users.pop("wazuh_admin", None)
        internal_users.pop("wazuh_user", None)
        yaml.dump(internal_users, file)
        
    with open("api_credentials.sh", "w") as file:
        file.write(f"export API_USERNAME=wazuh-wui\n")
        api_pass = api_users["wazuh-wui"]
        file.write(f"export API_PASSWORD={api_pass}\n")


if __name__ == "__main__":
    main()
