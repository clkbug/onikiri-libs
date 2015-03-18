
When boost libraries are updated, the following files must be updated manually:

  project\msvc\onikiri2\ExtractBoost.bat
  project\msvc\onikiri2\onikiri2.vcxproj.filters
  project\msvc\onikiri2\onikiri2.vcxproj
  project/gcc/boost/Makefile
  project/gcc/onikiri2/MakeCfg.xml

- You must replace definitions such as "boost_1_39_0" to a new version's ones.
- Several "*.cpp" files in boost must be added to a VS project manually.

