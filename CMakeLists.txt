project (/home/david/work/brickdm/CMakeLists.txt)

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/ev3dev-tk")
set (EXEC_NAME "ev3dev-tk-demo")
set (RELEASE_NAME "ev3dev graphical toolkit")
set (VERSION "0.1")
set (VERSION_INFO "alpha")

if(EV3DEV_TK_DESKTOP)
    set (EV3DEV_TK_DESKTOP_MODULES gtk+-3.0)
    set (EV3DEV_TK_DESKTOP_PACKAGES gtk+-3.0)
    set (EV3DEV_TK_SOURCE_FILES
        desktop-demo/main.vala
        src/desktop/FakeEV3LCDDevice.vala
        src/desktop/DesktopScreen.vala
    )
else(EV3DEV_TK_DESKTOP)
    set (EV3DEV_TK_SOURCE_FILES
        demo/main.vala
        src/ev3/EV3Screen.vala
        src/ConsoleApp.vala
    )
endif(EV3DEV_TK_DESKTOP)

set (EV3DEV_TK_COMMON_SOURCE_FILES
    demo/DemoWindow.vala
    src/Align.vala
    src/Box.vala
    src/Button.vala
    src/CheckButton.vala
    src/Container.vala
    src/Label.vala
    src/Rectangle.vala
    src/Screen.vala
    src/Scroll.vala
    src/Spacer.vala
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
    gee-1.0
    ncurses
    libpng
    ${EV3DEV_TK_DESKTOP_MODULES}
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} grx20 jpeg)
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
    gee-1.0
    curses
    posix
    linux
    ${EV3DEV_TK_DESKTOP_PACKAGES}
CUSTOM_VAPIS
    bindings/*.vapi
OPTIONS
    --target-glib=2.40
    #this option isn't in any released version of gcc yet, but will
    # be nice to have when it does get released.
    --Xcc=Wno-discarded-qualifiers
)

add_executable(${EXEC_NAME} ${VALA_C})

if (EV3DEV_TK_DESKTOP)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/desktop-demo/view/main_window.glade
    ${CMAKE_CURRENT_BINARY_DIR}/main_window.glade COPYONLY )
endif (EV3DEV_TK_DESKTOP)

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

