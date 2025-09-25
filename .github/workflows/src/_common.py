import os

main = os.environ.get("GITHUB_WORKSPACE", None)

if main is None:
    raise EnvironmentError("GITHUB_WORKSPACE environment variable is not set.")

pyproject_path = os.path.join(main, "helium")
pyproject_toml = os.path.join(pyproject_path, "pyproject.toml")
