import os
import sys

def generate_install_properties(template_path, output_path):
    """Reads a template and substitutes placeholders with environment variables."""
    
    # 1. Read the template content
    try:
        with open(template_path, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: Template file not found at {template_path}", file=sys.stderr)
        sys.exit(1)

    # 2. Define the list of variables to substitute
    # This list ensures we only replace the variables we intend to.
    variables = [
        "DB_FLAVOR", "SQL_CONNECTOR_JAR", "DB_HOST", "DB_PORT", "DB_NAME",
        "DB_USER", "DB_PASSWORD", "RANGER_ADMIN_PASSWORD", "KEYADMIN_PASSWORD",
        "RANGER_TAGSYNC_PASSWORD", "RANGER_USERSYNC_PASSWORD", "AUDIT_STORE"
    ]
    
    # 3. Perform the substitutions
    for var in variables:
        # Get the value from the environment. sys.exit if not found (critical failure).
        value = os.environ.get(var)
        if value is None:
            # Handle the combined DB_HOST:DB_PORT separately below
            if var not in ["DB_HOST", "DB_PORT"]: 
                print(f"Error: Environment variable {var} not set.", file=sys.stderr)
                sys.exit(1)

        # Handle the combined variable placeholder
        if var == "DB_HOST":
            db_host = os.environ.get("DB_HOST", "")
            db_port = os.environ.get("DB_PORT", "")
            content = content.replace("@@DB_HOST@@:@@DB_PORT@@", f"{db_host}:{db_port}")
        
        # Handle all single variable placeholders
        elif var != "DB_PORT":
            content = content.replace(f"@@{var}@@", value)

    # 4. Write the final content to the output file
    with open(output_path, 'w') as f:
        f.write(content)
    
    print(f"Successfully generated config file at {output_path}")

if __name__ == "__main__":
    # Check for correct arguments. In Docker, these paths are fixed.
    template_path = "/opt/ranger/security-admin/scripts/install.properties.template"
    output_path = "/opt/ranger/security-admin/scripts/install.properties"
    
    generate_install_properties(template_path, output_path)