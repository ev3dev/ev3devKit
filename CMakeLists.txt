project (/home/david/work/brickdm/CMakeLists.txt)

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/ev3devKit")
set (EXEC_NAME "ev3devKit-demo")
set (RELEASE_NAME "ev3dev toolkit")
set (VERSION "0.1")
set (VERSION_INFO "alpha")

if(EV3DEVKIT_DESKTOP)
    set (EV3DEVKIT_DESKTOP_MODULES gtk+-3.0)
    set (EV3DEVKIT_DESKTOP_PACKAGES gtk+-3.0)
    set (EV3DEV_TK_SOURCE_FILES
        desktop-demo/main.vala
        src/desktop/FakeEV3LCDDevice.vala
        src/desktop/DesktopScreen.vala
        src/desktop/DesktopTestApp.vala
    )
else(EV3DEVKIT_DESKTOP)
    set (EV3DEV_TK_SOURCE_FILES
        demo/main.vala
        src/ConsoleApp.vala
    )
endif(EV3DEVKIT_DESKTOP)

set (EV3DEV_TK_COMMON_SOURCE_FILES
    demo/DemoWindow.vala
    src/Align.vala
    src/Box.vala
    src/Button.vala
    src/CheckboxMenuItem.vala
    src/CheckButton.vala
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

find_package(PkgConfig REQUIRED)
pkg_check_modules(DEPS REQUIRED
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    ncurses
    libpng12
    ${EV3DEVKIT_DESKTOP_MODULES}
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} grx20 jpeg png)
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.24" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
    ${EV3DEV_TK_SOURCE_FILES}
    ${EV3DEV_TK_COMMON_SOURCE_FILES}
PACKAGES
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    curses
    posix
    linux
    ${EV3DEVKIT_DESKTOP_PACKAGES}
CUSTOM_VAPIS
    bindings/*.vapi
OPTIONS
    --target-glib=2.40
    --thread
)

add_executable(${EXEC_NAME} ${VALA_C})

if (EV3DEVKIT_DESKTOP)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/desktop/main_window.glade
    ${CMAKE_CURRENT_BINARY_DIR}/main_window.glade COPYONLY )
endif (EV3DEVKIT_DESKTOP)

add_custom_target(run
    COMMAND ${EXEC_NAME}
    DEPENDS ${EXEC_NAME}
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

find_package(Valadoc)

add_custom_target(doc
    COMMAND ${VALADOC_EXECUTABLE}
        --force
        --no-protected
        --package-name=${EXEC_NAME}
        --package-version=${VERSION}
        --target-glib=2.40
        -o ${CMAKE_BINARY_DIR}/doc
        --pkg=glib-2.0
        --pkg=gobject-2.0
        --pkg=gmodule-2.0
        --pkg=gio-2.0
        --pkg=gio-unix-2.0
        --pkg=gee-0.8
        --pkg=curses
        --pkg=posix
        --pkg=linux
        ${EV3DEV_TK_COMMON_SOURCE_FILES}
        bindings/*.vapi
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
