project ("ev3devKit")

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/ev3devKit")
set (EXEC_NAME "ev3devKit-demo")
set (VERSION "0.1")

set (LIBRARY_NAME "ev3devKit")
set (DESKTOP_LIBRARY_NAME "ev3devKit-desktop")
set (TARGET_GLIB "2.40")

set (COMMON_PACKAGES
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    curses
    posix
    linux
)
set (COMMON_MODULES
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    ncurses
    libpng12
)
set (DESKTOP_MODULES gtk+-3.0)
set (DESKTOP_PACKAGES gtk+-3.0)

if (EV3DEVKIT_DESKTOP)
    set (EXEC_SOURCE_FILES
        demo/DemoWindow.vala
        desktop-demo/main.vala
    )
else (EV3DEVKIT_DESKTOP)
    set (EXEC_SOURCE_FILES
        demo/DemoWindow.vala
        demo/main.vala
    )
endif (EV3DEVKIT_DESKTOP)

set (LIBRARY_SOURCE_FILES
    src/Box.vala
    src/Button.vala
    src/CheckboxMenuItem.vala
    src/CheckButton.vala
    src/ConsoleApp.vala
    src/Container.vala
    src/Dialog.vala
    src/Grid.vala
    src/Label.vala
    src/Menu.vala
    src/MenuItem.vala
    src/MessageDialog.vala
    src/Notebook.vala
    src/NotebookTab.vala
    src/OnScreenKeyboard.vala
    src/RadioMenuItem.vala
    src/Rectangle.vala
    src/Screen.vala
    src/Scroll.vala
    src/Spacer.vala
    src/StatusBar.vala
    src/StatusBarItem.vala
    src/TabButton.vala
    src/TextEntry.vala
    src/Widget.vala
    src/Window.vala
)

set (DESKTOP_LIBRARY_SOURCE_FILES
    src/desktop/FakeEV3LCDDevice.vala
    src/desktop/DesktopScreen.vala
    src/desktop/DesktopTestApp.vala
)

find_package (PkgConfig REQUIRED)
pkg_check_modules (DEPS REQUIRED
    ${COMMON_MODULES}
    ${DESKTOP_MODULES}
)
add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES} grx20 jpeg png)
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.24" MINIMUM)
include (ValaPrecompile)

vala_precompile (LIBRARY_VALA_C ${LIBRARY_NAME}
    ${LIBRARY_SOURCE_FILES}
PACKAGES
    ${COMMON_PACKAGES}
CUSTOM_VAPIS
    bindings/*.vapi
OPTIONS
    --target-glib=${TARGET_GLIB}
    --thread
GENERATE_VAPI
    ${LIBRARY_NAME}.buggy
GENERATE_HEADER
    ${LIBRARY_NAME}
)

add_custom_command (OUTPUT
    ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi
COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/fix-vapi.sh
    ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.buggy.vapi
    ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi
DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.buggy.vapi
COMMENT
    Fixing ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.buggy.vapi
)

if (EV3DEVKIT_DESKTOP)
vala_precompile (DESKTOP_LIBRARY_VALA_C ${DESKTOP_LIBRARY_NAME}
    ${DESKTOP_LIBRARY_SOURCE_FILES}
PACKAGES
    ${COMMON_PACKAGES}
    ${DESKTOP_PACKAGES}
CUSTOM_VAPIS
    bindings/*.vapi
    ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi
OPTIONS
    --target-glib=${TARGET_GLIB}
    --thread
GENERATE_VAPI
    ${DESKTOP_LIBRARY_NAME}
GENERATE_HEADER
    ${DESKTOP_LIBRARY_NAME}
)
endif(EV3DEVKIT_DESKTOP)


set (EXEC_PACKAGES ${COMMON_PACKAGES})
set (EXEC_VAPI ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi)

if (EV3DEVKIT_DESKTOP)
    list (APPEND EXEC_PACKAGES ${DESKTOP_PACKAGES})
    list (APPEND EXEC_VAPI ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_LIBRARY_NAME}.vapi)
endif (EV3DEVKIT_DESKTOP)

add_library (${LIBRARY_NAME} ${LIBRARY_VALA_C})

if (EV3DEVKIT_DESKTOP)
    add_library (${DESKTOP_LIBRARY_NAME} ${DESKTOP_LIBRARY_VALA_C})
    add_dependencies (${DESKTOP_LIBRARY_NAME} ${LIBRARY_NAME})
endif (EV3DEVKIT_DESKTOP)

# Workaround to make CMake 2.8 generate ev3devKit.vapi
# apparently add_custom_command is ignored if nothing depends on its output.
set (FIX_VAPI_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi)
if (EV3DEVKIT_DESKTOP)
    list (APPEND FIX_VAPI_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_LIBRARY_NAME}.vapi)
endif (EV3DEVKIT_DESKTOP)
add_custom_target (fix-vapi DEPENDS ${FIX_VAPI_DEPENDS})
add_dependencies (${LIBRARY_NAME} fix-vapi)

if (EV3DEVKIT_DESKTOP)
    configure_file (
        ${CMAKE_CURRENT_SOURCE_DIR}/src/desktop/main_window.glade
        ${CMAKE_CURRENT_BINARY_DIR}/main_window.glade COPYONLY
    )
endif (EV3DEVKIT_DESKTOP)

install (TARGETS ${LIBRARY_NAME} ARCHIVE DESTINATION lib)
if (EV3DEVKIT_DESKTOP)
    install (TARGETS ${DESKTOP_LIBRARY_NAME} ARCHIVE DESTINATION lib)
endif (EV3DEVKIT_DESKTOP)


if (NOT EV3DEVKIT_NO_DEMO)
    vala_precompile(EXEC_VALA_C ${EXEC_NAME}
        ${EXEC_SOURCE_FILES}
    PACKAGES
        ${EXEC_PACKAGES}
    CUSTOM_VAPIS
        bindings/*.vapi
        ${EXEC_VAPI}
    OPTIONS
        --target-glib=${TARGET_GLIB}
        --thread
    )

    set (EXEC_LIBRARY_DEPENDS ${LIBRARY_NAME})
    if (EV3DEVKIT_DESKTOP)
        list (APPEND EXEC_LIBRARY_DEPENDS ${DESKTOP_LIBRARY_NAME})
    endif (EV3DEVKIT_DESKTOP)

    add_executable (${EXEC_NAME} ${EXEC_VALA_C})
    add_dependencies (${EXEC_NAME} ${EXEC_LIBRARY_DEPENDS})
    target_link_libraries (${EXEC_NAME} ${EXEC_LIBRARY_DEPENDS})

    add_custom_target (run
        COMMAND ${EXEC_NAME}
        DEPENDS ${EXEC_NAME}
        WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
    )

    install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
endif (NOT EV3DEVKIT_NO_DEMO)

find_package (Valadoc)

set (DOC_DIR "${CMAKE_BINARY_DIR}/doc")

add_custom_target (docclean rm -rf ${DOC_DIR})

add_custom_target (doc
    COMMENT "Generating valadocs in ${DOC_DIR}"
    COMMAND ${VALADOC_EXECUTABLE}
        -o ${DOC_DIR}
        --package-name=${LIBRARY_NAME}
        --package-version=${VERSION}
        --target-glib=${TARGET_GLIB}
        --pkg=glib-2.0
        --pkg=gobject-2.0
        --pkg=gmodule-2.0
        --pkg=gio-2.0
        --pkg=gio-unix-2.0
        --pkg=gee-0.8
        --pkg=curses
        --pkg=posix
        --pkg=linux
        --pkg=gtk+-3.0
        --driver ${VALA_VERSION}
        ${LIBRARY_SOURCE_FILES}
        ${DESKTOP_LIBRARY_SOURCE_FILES}
        bindings/*.vapi
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    DEPENDS docclean
)
