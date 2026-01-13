set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Numpy includes are stored in the module itself
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)
set(VCPKG_BUILD_TYPE release) # No debug builds required for pure python modules since vcpkg does not install a debug python executable. 

#TODO: Fix E:\vcpkg_folders\numpy\installed\x64-windows-release\tools\python3\Lib\site-packages\numpy\testing\_private\extbuild.py

set(VCPKG_PYTHON3_BASEDIR "${CURRENT_HOST_INSTALLED_DIR}/tools/python3")
find_program(VCPKG_PYTHON3 NAMES python${PYTHON3_VERSION_MAJOR}.${PYTHON3_VERSION_MINOR} python${PYTHON3_VERSION_MAJOR} python PATHS "${VCPKG_PYTHON3_BASEDIR}" NO_DEFAULT_PATH)
find_program(VCPKG_CYTHON NAMES cython PATHS "${VCPKG_PYTHON3_BASEDIR}" "${VCPKG_PYTHON3_BASEDIR}/Scripts" NO_DEFAULT_PATH)

set(ENV{PYTHON3} "${VCPKG_PYTHON3}")
set(PYTHON3 "${VCPKG_PYTHON3}")
# not sure why, but for some reason, this gets reset, and 
# vcpkg_python_build_and_install_wheel attempts to use the system python
set(z_vcpkg_python_func_python ${PYTHON3})

vcpkg_add_to_path(PREPEND "${VCPKG_PYTHON3_BASEDIR}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_add_to_path(PREPEND "${VCPKG_PYTHON3_BASEDIR}/Scripts")
endif()

cmake_path(GET SCRIPT_MESON PARENT_PATH MESON_DIR)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numpy/numpy
    REF v${VERSION}
    SHA512 a034c14589989b04c178ba0be75fbfe5ec803a057742ac5191d245e3275d427e3be59980cb96ea2d9d4dec6706781899a9d64c99be5b9682a2ff81298b96e032
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_SIMD
    REPO intel/x86-simd-sort
    REF 8a7208187d99f0cb67e38c57ab1c7c85aad07aca
    SHA512 4cf2462890306fbd744b3bf40aada62d13743fafe113f469bd6816a48234a83ed552ec4f2924668a94e468c7629e91f8dc6d54368a669db02f48fa872d6ad9e0
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_SIMD}/" DESTINATION "${SOURCE_PATH}/numpy/_core/src/npysort/x86-simd-sort")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_MESON_NUMPY
    REPO numpy/meson
    REF 5d5a3d478da115c812be77afa651db2492d52171
    SHA512 7045d09b123fac0d305071283357e2ee66c6cd2b0459f62b7a27194c68bfc734bf2675ba49ca48fcc738e160dfea9b648e70bd9361afe42a8722c3dfd2f4fd3d
    HEAD_REF main-numpymeson
)

file(COPY "${SOURCE_PATH_MESON_NUMPY}/mesonbuild/modules/features" DESTINATION "${MESON_DIR}/mesonbuild/modules")
#file(COPY "${SOURCE_PATH_MESON_NUMPY}/" DESTINATION "${SOURCE_PATH}/vendored-meson/meson")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_SVML
    REPO numpy/SVML
    REF 3a713b13018325451c1b939d3914ceff5ec68e19
    SHA512 aa2d1f83a7fdc1c5b31f51c4d8d3ffd2604be68011584ec30e1e18522f9b36c39d613e9e9e4e1b100548b5db42f3cb60d95d042f3d523802103de90f617a8b66
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_SVML}/" DESTINATION "${SOURCE_PATH}/numpy/_core/src/umath/svml")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_HIGHWAY
    REPO google/highway
    REF ac0d5d297b13ab1b89f48484fc7911082d76a93f
    SHA512 0736644d3a674d85852980a26f3fa1431522e082f3e1834ab71a9169093c9ff3ab10f030b8139708db4261de81e8725c9554112942468f8f378da29b7506324f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH_HIGHWAY}/" DESTINATION "${SOURCE_PATH}/numpy/_core/src/highway")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_CAPICOMPAT
    REPO python/pythoncapi-compat
    REF 11cb80f2652cb2fe5231bf60b9dd98c83a4e25f4
    SHA512 0d3ca2ada19e0a42570846b1f6f5938e37873d6fd6fc36cce896fd9384a6569580250959b4357d008b06b9dcddf26a2af051dd01fda16f7651889f4a658d0638
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_CAPICOMPAT}/" DESTINATION "${SOURCE_PATH}/numpy/_core/src/common/pythoncapi-compat")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_POCKETFFT
    REPO mreineck/pocketfft
    REF d746b2bb5368e0aa6b75de1d83dc7aae46e7da80
    SHA512 a6a520d61f050ef16d3e87e64362448c315bbc6d8ae6060b570ebdbb7f38435a43fbac5c5cba3035c1402526a2be39184f52bfae79fc74b03df595cdc8bf8105
    HEAD_REF cpp
)

file(COPY "${SOURCE_PATH_POCKETFFT}/" DESTINATION "${SOURCE_PATH}/numpy/fft/pocketfft")

vcpkg_replace_string("${SOURCE_PATH}/meson.build" "py.dependency()" "dependency('python-3.${PYTHON3_VERSION_MINOR}', method : 'pkg-config')")


if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CROSSCOMPILING AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
  set(opts 
      ADDITIONAL_PROPERTIES
      "longdouble_format = 'IEEE_DOUBLE_LE'"
  )
endif()

vcpkg_mesonpy_prepare_build_options(OUTPUT meson_opts)

z_vcpkg_setup_pkgconfig_path(CONFIG "RELEASE")

list(APPEND meson_opts  "--python.platlibdir" "${CURRENT_INSTALLED_DIR}/lib")
list(JOIN meson_opts "\",\""  meson_opts)

vcpkg_python_build_and_install_wheel(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
    --config-json "{\"setup-args\" : [\"${meson_opts}\" ] }" 
)
vcpkg_fixup_pkgconfig(SKIP_CHECK)
vcpkg_copy_tools(TOOL_NAMES f2py numpy-config DESTINATION "${CURRENT_PACKAGES_DIR}/tools/python3" AUTO_CLEAN)
#E:\vcpkg_folders\numpy\packages\numpy_arm64-windows-release\tools\python3\Lib\site-packages\numpy\__config__.py
# "path": r"E:/vcpkg_folders/numpy/installed/x64-windows-release/tools/python3/python.exe", and full paths to compilers
#"commands": "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.39.33519/bin/Hostx64/arm64/cl.exe, -DWIN32, -D_WINDOWS, -W3, -utf-8, -MP, -MD, -O2, -Oi, -Gy, -DNDEBUG, -Z7",

set(subdir "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/")
if(VCPKG_TARGET_IS_WINDOWS)
  set(subdir "${CURRENT_PACKAGES_DIR}/lib/site-packages/")
endif()
set(pyfile "${subdir}/numpy/__config__.py")
file(READ "${pyfile}" contents)
string(REPLACE "${CURRENT_INSTALLED_DIR}" "$(prefix)" contents "${contents}")
string(REPLACE "r\"${VCPKG_PYTHON3}\"" "sys.executable" contents "${contents}")
file(WRITE "${pyfile}" "${contents}")


if(VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/site-packages/numpy" "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/numpy")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

# Add required Metadata for some python build plugins
file(WRITE "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/numpy-${VERSION}.dist-info/METADATA"
"Metadata-Version: 2.1\n\
Name: numpy\n\
Version: ${VERSION}"
)

vcpkg_python_test_import(MODULE "numpy")
