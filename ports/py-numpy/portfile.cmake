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
    SHA512 33f39b7acf79a3e0e697736ccb330b4d7d3868aff8224d633e4e2ebd02f13d3986cf868fb2f860dcf7c1011992a65d839441c5f0251108ae1d70467fa3711de0
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_SIMD
    REPO intel/x86-simd-sort
    REF 6a7a01da4b0dfde108aa626a2364c954e2c50fe1 
    SHA512 22e398b88fa998d3451d82345c45bb3be345c7fe9e3434788eb7e8f6cb54b561b7dc79d5f3c6d28b426a87a0966ca06f8591748f90ccae7993f853e05d63e469
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
    REF ee36c837129310be19c17c9108c6dc3f6ae06942
    SHA512 8c2a34a329e9b4c239ded17f906756e79cfc6afd47711ce17eaf7ffab74ae8c7f60bd64b81cfa5eaa2338779998373e1a2c5cb4c97c7a2e8ca7b0514622e8bdb
    HEAD_REF master
)

file(COPY "${SOURCE_PATH_HIGHWAY}/" DESTINATION "${SOURCE_PATH}/numpy/_core/src/highway")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_CAPICOMPAT
    REPO python/pythoncapi-compat
    REF 90c06a4cae557bdbfa4f231a781d2b5c1a8f6d1c
    SHA512 a6540a70337f994254930c310f80497b75c76315ed9b7e478247ce4b52ff615bba28f7b0bcef82e16f99b7b8baee030eb69184d8ad7b563e059988bcff58aed5
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_CAPICOMPAT}/" DESTINATION "${SOURCE_PATH}/numpy/_core/src/common/pythoncapi-compat")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_POCKETFFT
    REPO mreineck/pocketfft
    REF 33ae5dc94c9cdc7f1c78346504a85de87cadaa12
    SHA512 2acd1b2c4419a2a817e5fdc7770e8f9dae991a7b45c115651eb4df489f28b7ae8d088806bc100434bb9a6c77c02018c3ee14315c3c02c0dc433f18d8fbf064ad
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
