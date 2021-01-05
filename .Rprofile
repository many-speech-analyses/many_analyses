source("renv/activate.R")

# Load environment variables if "~/.secrets" exists in your home dir.
# You can store your OSF_PAT by adding the following to "~/.secrets":
#
#     Sys.setenv(OSF_PAT = "<your-pat-here>")
#
if (file.exists("~/.secrets")) {
  source("~/.secrets")
  # Nerdy message to let you know that the variables have been loaded into your
  # session.
  cat(crayon::green("Your secrets have been spilled..."))
}
