using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Pluto

Pluto.run(host = "0.0.0.0", port = 1234, launch_browser = false, require_secret_for_open_links = false, require_secret_for_access = false, dismiss_update_notification = true, show_file_system = true)
