vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesonbuild/meson-python
    REF ${VERSION}
    SHA512 f32f02851cdfc13f29550b297b3bce9038bdaf02381b15064e36442104e93624e090abeae23b9de97dfa971aa456716cae65dbe04784beee13b510db12de1000
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_install_meson()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/python3/Lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/Lib/site-packages/" "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/Lib")
endif()

vcpkg_python_test_import(MODULE "mesonpy")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg_mesonpy_prepare_build_options.cmake"
          DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
