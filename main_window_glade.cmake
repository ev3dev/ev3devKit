# Add contents of main_window.glade as text to main_window_glade.vala
# Note: Caller must set SOURCE_DIR and BINARY_DIR since CMAKE_SOURCE_DIR gives
# an incorrect value.

file (READ ${SOURCE_DIR}/src/desktop/main_window.glade MAIN_WINDOW_GLADE)
configure_file (
    ${SOURCE_DIR}/src/desktop/main_window_glade.vala.in
    ${BINARY_DIR}/main_window_glade.vala
)
