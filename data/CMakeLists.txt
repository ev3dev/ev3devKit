set (files
    bluetooth12x12
    bluetooth7x9
    bluetooth-connected7x9
    ethernet12x12
    lock5x6
    lock7x9
    usb12x12
    usb7x9
    wifi-idle12x9
    wifi12x12
    wifi12x9
    wps9x9
)

set (generated_files "")
foreach (file ${files})
    set (in_file ${CMAKE_CURRENT_SOURCE_DIR}/${file}.pbm)
    set (out_file ${CMAKE_BINARY_DIR}/${file}.png)
    list (APPEND generated_files ${out_file})
    add_custom_command (
        OUTPUT
            ${out_file}
        COMMAND
            ${CMAKE_COMMAND} -Din_file="${in_file}" -Dout_file="${out_file}" -P ${CMAKE_CURRENT_SOURCE_DIR}/pnmtopng.cmake
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS
            ${in_file})
endforeach (file)

add_custom_target (ev3devkit_data
    DEPENDS
        ${generated_files})

install (
    FILES
        ${generated_files}
    DESTINATION
        share/${CMAKE_PROJECT_NAME})
