FROM ubuntu:20.04
LABEL maintainer="Andrew Van <vanandrew@wustl.edu>"

### Base dependencies ###
RUN apt-get update && apt-get install -y wget dirmngr tcsh curl make gfortran git unzip

### Compile and install fsl from source ###
WORKDIR /opt
ENV FSLDIR=/opt/fsl
RUN curl -O https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.5-sources.tar.gz && \
	tar zxf fsl-6.0.5-sources.tar.gz && \
	rm fsl-6.0.5-sources.tar.gz
RUN apt-get install -y build-essential libexpat1-dev libx11-dev libgl1-mesa-dev libglu1-mesa-dev zlib1g-dev \
    libopenblas-dev liblapack-dev
WORKDIR ${FSLDIR}
RUN sed -i 's/ > .\/build.log 2>&1/;/g' build && \
    sed -i 's/return input_;/return static_cast<bool>(input_);/g' \
    extras/src/libxmlpp/libxml++/io/istreamparserinputbuffer.cc && \
    sed -i 's/return output_;/return static_cast<bool>(output_);/g' \
    extras/src/libxmlpp/libxml++/io/ostreamoutputbuffer.cc && \
    sed -i 's/${LIBS}/${LIBS} -llapack -lblas/g' src/*/Makefile && \
    sed -i 's/${LIBS++}/${LIBS++} -llapack -lblas/g' src/*/Makefile && \
    sed -i 's/$(LIBS)/$(LIBS) -llapack -lblas/g' src/*/Makefile && \
    sed -i 's/${DLIBS}/${DLIBS} -llapack -lblas/g' src/*/Makefile && \
    sed -i 's/${ILIBS}/${ILIBS} -llapack -lblas/g' src/*/Makefile && \
    sed -i 's/${CLIBS}/${CLIBS} -llapack -lblas/g' src/*/Makefile
RUN ./build extras
RUN ./build CiftiLib-master \
            utils \
            znzlib \
            NewNifti \
            niftiio \
            fslio \
            giftiio \
            miscmaths \
            newimage \
            libhfunc \
            libvis \
            first_lib \
            meshclass \
            fslvtkio \
            misc_tcl \
            basisfield \
            warpfns \
            bint \
            shapeModel \
            MVdisc \
            fslvtkconv \
            fslsurface \
            libmeshutils \
            newmesh \
            DiscreteOpt \
            FastPDlib \
            MSMRegLib \
            misc_c \
            dpm \
            topup
RUN apt-get install -y python3 python-is-python3 python3-setuptools && \
    sed -i 's/${FMBLIBS}/${FMBLIBS} -llapack -lblas/g' src/first/Makefile && \
    sed -i 's/COMPILE_GPU = 1/COMPILE_GPU = 0/g' config/buildSettings.mk && \
    sed -i 's/-lm  -lgdc -lgd -lpng -lz/-lgdc -lgd -lpng -lm -lz/g' src/miscvis/Makefile && \
    sed -i 's/${LIBCC}/${LIBCC} -llapack -lblas/g' src/siena/Makefile
RUN MAKEOPTIONS=-j4 ./build asl_mfree \
                            avwutils \
                            basil \
                            baycest \
                            bet2 \
                            bianca \
                            cluster \
                            copain \
                            fsl_deface \
                            dwssfp \
                            eddy \
                            fabber_core \
                            fabber_models_asl \
                            fabber_models_cest \
                            fabber_models_dce \
                            fabber_models_dsc \
                            fabber_models_dualecho \
                            fabber_models_dwi \
                            fabber_models_t1 \
                            fabber_models_qbold \
                            fast4 \
                            fdt \
                            feat5 \
                            film \
                            filmbabe \
                            first \
                            flameo \
                            flirt \
                            fnirt \
                            fslpres \
                            fslvbm \
                            fugue \
                            gps \
                            ifit \
                            lesions \
                            load_dicom \
                            load_varian \
                            mcflirt \
                            melodic \
                            misc_scripts \
                            miscvis \
                            mm \
                            MSM \
                            nma \
                            oxford_asl \
                            possum \
                            ptx2 \
                            qboot \
                            randomise \
                            relax \
                            sgeutils \
                            siena \
                            slicetimer \
                            susan \
                            swe \
                            tbss \
                            tissue \
                            verbena \
                            xtract
# disable distclean for fast builds, after depends.mk are generated from the first build pass
RUN sed -i 's/${MAKE} distclean ;/# ${MAKE} distclean ;/g' config/common/buildproj
ENV FSLOUTPUTTYPE=NIFTI_GZ FSLMULTIFILEQUIT=TRUE FSLTCLSH=${FSLDIR}/bin/fsltclsh FSLWISH=${FSLDIR}/fslwish \
    PATH=${PATH}:${FSLDIR}/bin
