project ("ev3devKit")

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/ev3devKit")
set (DEVICES_DEMO_EXEC_NAME "ev3devKit-devices-demo")
set (UI_DEMO_EXEC_NAME "ev3devKit-ui-demo")
set (VERSION "0.1")

set (PACKAGE_NAME "EV3devKit")
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
    gudev-1.0
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
    gudev-1.0
    ncurses
)
set (DESKTOP_MODULES gtk+-3.0)
set (DESKTOP_PACKAGES gtk+-3.0)

if (EV3DEVKIT_DESKTOP)
    set (UI_DEMO_SOURCE_FILES
        demo/UIDemoWindow.vala
        demo/ui_desktop_demo.vala
    )
else (EV3DEVKIT_DESKTOP)
    set (UI_DEMO_SOURCE_FILES
        demo/UIDemoWindow.vala
        demo/ui_demo.vala
    )
endif (EV3DEVKIT_DESKTOP)

set (DEVICES_DEMO_SOURCE_FILES
    demo/devices_demo.vala
)

set (LIBRARY_SOURCE_FILES
    src/devices/DCMotor.vala
    src/devices/Device.vala
    src/devices/DeviceManager.vala
    src/devices/LED.vala
    src/devices/Port.vala
    src/devices/PowerSupply.vala
    src/devices/Sensor.vala
    src/devices/ServoMotor.vala
    src/devices/TachoMotor.vala
    src/ui/Box.vala
    src/ui/Button.vala
    src/ui/CheckboxMenuItem.vala
    src/ui/CheckButton.vala
    src/ui/Container.vala
    src/ui/Dialog.vala
    src/ui/Grid.vala
    src/ui/Label.vala
    src/ui/Menu.vala
    src/ui/MenuItem.vala
    src/ui/MessageDialog.vala
    src/ui/Notebook.vala
    src/ui/NotebookTab.vala
    src/ui/OnScreenKeyboard.vala
    src/ui/RadioMenuItem.vala
    src/ui/Rectangle.vala
    src/ui/Screen.vala
    src/ui/Scroll.vala
    src/ui/Spacer.vala
    src/ui/StatusBar.vala
    src/ui/StatusBarItem.vala
    src/ui/TabButton.vala
    src/ui/TextEntry.vala
    src/ui/Widget.vala
    src/ui/Window.vala
    src/ConsoleApp.vala
)

set (DESKTOP_LIBRARY_SOURCE_FILES
    src/desktop/GtkApp.vala
    src/desktop/GtkFramebuffer.vala
    src/desktop/GtkScreen.vala
)

set (MODULES ${COMMON_MODULES})
if (EV3DEVKIT_DESKTOP)
    list (APPEND MODULES ${DESKTOP_MODULES})
endif (EV3DEVKIT_DESKTOP)

find_package (PkgConfig REQUIRED)
pkg_check_modules (DEPS REQUIRED ${MODULES})
add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES} grx20 m)
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.24" MINIMUM)
include (ValaPrecompile)

vala_precompile (LIBRARY_VALA_C ${LIBRARY_NAME}
LIBRARY
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
GENERATE_GIR TYPELIB
    ${PACKAGE_NAME}-${VERSION}
)

add_library (${LIBRARY_NAME} SHARED ${LIBRARY_VALA_C})
install (TARGETS ${LIBRARY_NAME} LIBRARY DESTINATION lib)

# There is a bug in valac that causes an unowned compact class to lose
# the "unowned" qualifier when generating a vapi. So, we are calling a
# script we wrote to fix it.
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

# Workaround to make CMake 2.8 generate ev3devKit.vapi
# apparently add_custom_command is ignored if nothing depends on its output.
set (FIX_VAPI_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi)
add_custom_target (fix-vapi DEPENDS ${FIX_VAPI_DEPENDS})
add_dependencies (${LIBRARY_NAME} fix-vapi)

if (EV3DEVKIT_DESKTOP)
    vala_precompile (DESKTOP_LIBRARY_VALA_C ${DESKTOP_LIBRARY_NAME}
    LIBRARY
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

    add_library (${DESKTOP_LIBRARY_NAME} SHARED ${DESKTOP_LIBRARY_VALA_C})
    add_dependencies (${DESKTOP_LIBRARY_NAME} ${LIBRARY_NAME})
    install (TARGETS ${DESKTOP_LIBRARY_NAME} LIBRARY DESTINATION lib)
    configure_file (
        ${CMAKE_CURRENT_SOURCE_DIR}/src/desktop/main_window.glade
        ${CMAKE_CURRENT_BINARY_DIR}/main_window.glade COPYONLY
    )
endif (EV3DEVKIT_DESKTOP)

if (NOT EV3DEVKIT_NO_DEMO)

    set (EXEC_PACKAGES ${COMMON_PACKAGES})
    set (EXEC_VAPI ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}.vapi)

    if (EV3DEVKIT_DESKTOP)
        list (APPEND EXEC_PACKAGES ${DESKTOP_PACKAGES})
        list (APPEND EXEC_VAPI ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_LIBRARY_NAME}.vapi)
    endif (EV3DEVKIT_DESKTOP)

    set (EXEC_LIBRARY_DEPENDS ${LIBRARY_NAME})
    if (EV3DEVKIT_DESKTOP)
        list (APPEND EXEC_LIBRARY_DEPENDS ${DESKTOP_LIBRARY_NAME})
    endif (EV3DEVKIT_DESKTOP)

    # Device driver demo program

    vala_precompile(DEVICES_DEMO_EXEC_VALA_C ${DEVICES_DEMO_EXEC_NAME}
        ${DEVICES_DEMO_SOURCE_FILES}
    PACKAGES
        ${EXEC_PACKAGES}
    CUSTOM_VAPIS
        bindings/*.vapi
        ${EXEC_VAPI}
    OPTIONS
        --target-glib=${TARGET_GLIB}
        --thread
    )

    add_executable (${DEVICES_DEMO_EXEC_NAME} ${DEVICES_DEMO_EXEC_VALA_C})
    target_link_libraries (${DEVICES_DEMO_EXEC_NAME} ${EXEC_LIBRARY_DEPENDS})

    add_custom_target (run-${DEVICES_DEMO_EXEC_NAME}
        COMMAND ${DEVICES_DEMO_EXEC_NAME}
        DEPENDS ${DEVICES_DEMO_EXEC_NAME}
        WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
    )

    install (TARGETS ${DEVICES_DEMO_EXEC_NAME} RUNTIME DESTINATION bin)

    # User interface demo program

    vala_precompile(UI_DEMO_EXEC_VALA_C ${UI_DEMO_EXEC_NAME}
        ${UI_DEMO_SOURCE_FILES}
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

    add_executable (${UI_DEMO_EXEC_NAME} ${UI_DEMO_EXEC_VALA_C})
    target_link_libraries (${UI_DEMO_EXEC_NAME} ${EXEC_LIBRARY_DEPENDS})

    add_custom_target (run-${UI_DEMO_EXEC_NAME}
        COMMAND ${UI_DEMO_EXEC_NAME}
        DEPENDS ${UI_DEMO_EXEC_NAME}
        WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
    )

    install (TARGETS ${UI_DEMO_EXEC_NAME} RUNTIME DESTINATION bin)
endif (NOT EV3DEVKIT_NO_DEMO)

find_package (Valadoc)
if (VALADOC_FOUND)
    include (ValadocGenerate)
    generate_valadoc (
        ${LIBRARY_SOURCE_FILES}
        ${DESKTOP_LIBRARY_SOURCE_FILES}
        bindings/*.vapi
    PACKAGE_NAME
        ${LIBRARY_NAME}
    PACKAGE_VERSION
        ${VERSION}
    OPTIONS
        --target-glib=${TARGET_GLIB}
    PACKAGES
        ${COMMON_PACKAGES}
        ${DESKTOP_PACKAGES}
    )
endif (VALADOC_FOUND)
