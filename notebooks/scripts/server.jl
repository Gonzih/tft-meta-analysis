# using PlutoSliderServer
# PlutoSliderServer.run_directory("/notebooks"; SliderServer_host="0.0.0.0")

using Pluto

Pluto.run(host="0.0.0.0", port=8888, launch_browser=false, require_secret_for_open_links=false, require_secret_for_access=false, dismiss_update_notification=true, show_file_system=true)
