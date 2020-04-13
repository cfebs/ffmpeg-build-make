JOBS := $(shell nproc)
WORKSPACE := $(PWD)/workspace
DIR := $(PWD)/
CACHE_DIR := $(PWD)/.cache
DL_DIR := $(PWD)/.dl
SRC_DIR := $(PWD)/.src
OUT_BIN_DIR := $(PWD)/bin

FFMPEG_VERSION := snapshot
FFMPEG_SRC := https://ffmpeg.org/releases/ffmpeg-$(FFMPEG_VERSION).tar.bz2

YASM_VERSION := 1.3.0
YASM_SRC := http://www.tortall.net/projects/yasm/releases/yasm-$(YASM_VERSION).tar.gz

NASM_VERSION := 2.14.02
NASM_SRC := https://www.nasm.us/pub/nasm/releasebuilds/$(NASM_VERSION)/nasm-$(NASM_VERSION).tar.gz

X264_VERSION := master
X264_SRC := https://code.videolan.org/videolan/x264/-/archive/$(X264_VERSION)/x264-$(X264_VERSION).tar.gz

X265_VERSION := default
X265_SRC := https://bitbucket.org/multicoreware/x265/get/$(X265_VERSION).tar.gz

LIBVPX_VERSION := master
LIBVPX_SRC := https://chromium.googlesource.com/webm/libvpx.git/+archive/refs/heads/$(LIBVPX_VERSION).tar.gz

LIBFDKAAC_VERSION := master
LIBFDKAAC_SRC := https://github.com/mstorsjo/fdk-aac/archive/$(LIBFDKAAC_VERSION).tar.gz

LIBMP3LAME_VERSION := 3.100
LIBMP3LAME_SRC := https://downloads.sourceforge.net/project/lame/lame/$(LIBMP3LAME_VERSION)/lame-$(LIBMP3LAME_VERSION).tar.gz

LIBOPUS_VERSION := master
LIBOPUS_SRC := https://github.com/xiph/opus/archive/$(LIBOPUS_VERSION).tar.gz

LIBAOM_VERSION := master
LIBAOM_SRC := https://aomedia.googlesource.com/aom/+archive/refs/heads/$(LIBAOM_VERSION).tar.gz

$(CACHE_DIR)/prereq:
	@mkdir -p $(CACHE_DIR) $(DL_DIR) $(SRC_DIR) $(WORKSPACE) $(OUT_BIN_DIR)
	touch $@

## yasm
$(DL_DIR)/yasm-$(YASM_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(YASM_SRC) -o $@

$(CACHE_DIR)/yasm: $(DL_DIR)/yasm-$(YASM_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/yasm-$(YASM_VERSION) && \
		./configure --prefix=$(WORKSPACE) && \
		make -j $(JOBS) && \
		make install && \
		touch $@

## nasm
$(DL_DIR)/nasm-$(NASM_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(NASM_SRC) -o $@ && tar -tvf >/dev/null $@

$(CACHE_DIR)/nasm: $(DL_DIR)/nasm-$(NASM_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/nasm-$(NASM_VERSION) && \
		./autogen.sh && \
		./configure --prefix=$(WORKSPACE) && \
		make -j $(JOBS) && \
		make install && \
		touch $@

## x264
$(DL_DIR)/x264-$(X264_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(X264_SRC) -o $@ && tar -tvf >/dev/null $@

$(CACHE_DIR)/x264: $(DL_DIR)/x264-$(X264_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/x264-$(X264_VERSION) && \
		./configure --prefix=$(WORKSPACE) --enable-static --enable-pic && \
		make -j $(JOBS) && \
		make install && \
		touch $@

## x265
$(DL_DIR)/x265-$(X265_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(X265_SRC) -o $@ && tar -tvf >/dev/null $@

$(CACHE_DIR)/x265: $(DL_DIR)/x265-$(X265_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/multicoreware-x265-* && \
		cd source && \
		cmake -DCMAKE_INSTALL_PREFIX=$(WORKSPACE) -DENABLE_SHARED:bool=off . && \
		make -j $(JOBS) && \
		make install && \
		touch $@

## libvpx
$(DL_DIR)/libvpx-$(LIBVPX_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(LIBVPX_SRC) -o $@ && tar -tvf >/dev/null $@

$(CACHE_DIR)/libvpx: $(DL_DIR)/libvpx-$(LIBVPX_VERSION).tar.gz
	mkdir -p $(SRC_DIR)/libvpx-$(LIBVPX_VERSION)
	tar -xvf $< -C $(SRC_DIR)/libvpx-$(LIBVPX_VERSION) && \
		cd $(SRC_DIR)/libvpx-$(LIBVPX_VERSION) && \
		./configure --prefix=$(WORKSPACE) --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
		make -j $(JOBS) && \
		make install && \
		touch $@

# libfdk_aac
$(DL_DIR)/libfdkaac-$(LIBFDKAAC_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(LIBFDKAAC_SRC) -o $@ && tar -tvf >/dev/null $@

$(CACHE_DIR)/libfdkaac: $(DL_DIR)/libfdkaac-$(LIBFDKAAC_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/fdk-aac-$(LIBFDKAAC_VERSION) && \
		autoreconf -fiv && \
		./configure --prefix=$(WORKSPACE) --disable-shared && \
		make -j $(JOBS) && \
		make install && \
		touch $@

# libmp3lame
$(DL_DIR)/libmp3lame-$(LIBMP3LAME_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(LIBMP3LAME_SRC) -o $@ && \
		tar -tvf >/dev/null $@ || rm -f $@

$(CACHE_DIR)/libmp3lame: $(DL_DIR)/libmp3lame-$(LIBMP3LAME_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/lame-$(LIBMP3LAME_VERSION) && \
		./configure --prefix=$(WORKSPACE) --disable-shared --enable-nasm && \
		make -j $(JOBS) && \
		make install && \
		touch $@

# libopus
$(DL_DIR)/libopus-$(LIBOPUS_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(LIBOPUS_SRC) -o $@ && \
		tar -tvf >/dev/null $@ || rm -f $@

$(CACHE_DIR)/libopus: $(DL_DIR)/libopus-$(LIBOPUS_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/opus-$(LIBOPUS_VERSION) && \
		./autogen.sh && \
		./configure --prefix=$(WORKSPACE) --disable-shared && \
		make -j $(JOBS) && \
		make install && \
		touch $@

# libaom
$(DL_DIR)/libaom-$(LIBAOM_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(LIBAOM_SRC) -o $@ && tar -tvf >/dev/null $@

$(CACHE_DIR)/libaom: $(DL_DIR)/libaom-$(LIBAOM_VERSION).tar.gz
	mkdir -p $(SRC_DIR)/aom-$(LIBAOM_VERSION)
	tar -xvf $< -C $(SRC_DIR)/aom-$(LIBAOM_VERSION) && \
		mkdir -p $(SRC_DIR)/aom_build && \
		cd $(SRC_DIR)/aom_build && \
		cmake -DCMAKE_INSTALL_PREFIX=$(WORKSPACE) -DENABLE_SHARED=off -DENABLE_NASM=on ../aom-$(LIBAOM_VERSION) && \
		make -j $(JOBS) && \
		make install && \
		touch $@


# ffmpeg
$(DL_DIR)/ffmpeg-$(FFMPEG_VERSION).tar.gz: $(CACHE_DIR)/prereq
	curl -L $(FFMPEG_SRC) -o $@ && \
		tar -tvf >/dev/null $@ || rm -f $@

$(CACHE_DIR)/ffmpeg: $(CACHE_DIR)/yasm $(CACHE_DIR)/nasm $(CACHE_DIR)/x264 $(CACHE_DIR)/x265 $(CACHE_DIR)/libvpx $(CACHE_DIR)/libfdkaac $(CACHE_DIR)/libmp3lame $(CACHE_DIR)/libopus $(CACHE_DIR)/libaom $(DL_DIR)/ffmpeg-$(FFMPEG_VERSION).tar.gz
	tar -xvf $< -C $(SRC_DIR) && \
		cd $(SRC_DIR)/ffmpeg && \
		PKG_CONFIG_PATH="$(WORKSPACE)/lib/pkgconfig" ./configure \
		  --prefix="$(WORKSPACE)" \
		  --pkg-config-flags="--static" \
		  --extra-cflags="-I$(WORKSPACE)/include" \
		  --extra-ldflags="-L$(WORKSPACE)/lib" \
		  --extra-libs="-lpthread -lm" \
		  --bindir="$(WORKSPACE)/bin" \
		  --enable-gpl \
		  --enable-libaom \
		  --enable-libass \
		  --enable-libfdk-aac \
		  --enable-libfreetype \
		  --enable-libmp3lame \
		  --enable-libopus \
		  --enable-libvorbis \
		  --enable-libvpx \
		  --enable-libx264 \
		  --enable-libx265 \
		  --enable-nonfree && \
		make -j $(JOBS) && \
		make install && \
		touch $@

.PHONY:all
all: $(CACHE_DIR)/ffmpeg

.PHONY: clean
clean:
	rm -rf $(CACHE_DIR) $(OUT_BIN_DIR)

.PHONY:distclean
distclean:
	rm -rf $(CACHE_DIR) $(DL_DIR) $(SRC_DIR) $(WORKSPACE) $(OUT_BIN_DIR)
