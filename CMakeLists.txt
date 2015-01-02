project (/home/david/work/brickdm/CMakeLists.txt)

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/ev3dev-lang-vala")
set (EXEC_NAME "ev3dev-lang-vala-demo")
set (RELEASE_NAME "ev3dev vala language library")
set (VERSION "0.1")
set (VERSION_INFO "alpha")

if(EV3DEV_LANG_VALA_DEMO)
    set (EV3DEV_LANG_VALA_SOURCE_FILES
        demo/Demo.vala
    )
endif(EV3DEV_LANG_VALA_DEMO)

set (EV3DEV_LANG_VALA_COMMON_SOURCE_FILES
    src/DCMotor.vala
    src/Device.vala
    src/DeviceManager.vala
    src/LED.vala
    src/Port.vala
    src/Sensor.vala
    src/TachoMotor.vala
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(DEPS REQUIRED
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    gudev-1.0
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} m)
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.24" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
    ${EV3DEV_LANG_VALA_SOURCE_FILES}
    ${EV3DEV_LANG_VALA_COMMON_SOURCE_FILES}
PACKAGES
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    gudev-1.0
OPTIONS
    --target-glib=2.40
    --thread
)

add_executable(${EXEC_NAME} ${VALA_C})

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
        --pkg=gio-2.0
        --pkg=gee-0.8
        --pkg=gudev-1.0
        ${EV3DEV_LANG_VALA_SOURCE_FILES}
        ${EV3DEV_LANG_VALA_COMMON_SOURCE_FILES}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
