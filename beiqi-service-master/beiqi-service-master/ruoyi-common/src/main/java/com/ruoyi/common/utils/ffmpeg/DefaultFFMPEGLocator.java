/*
 * JAVE - A Java Audio/Video Encoder (based on FFMPEG)
 *
 * Copyright (C) 2008-2009 Carlo Pelliccia (www.sauronsoftware.it)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.ruoyi.common.utils.ffmpeg;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.io.resource.ClassPathResource;
import cn.hutool.core.util.ZipUtil;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.exception.file.FileException;
import org.springframework.util.FileCopyUtils;

import java.io.*;

/**
 * The default ffmpeg executable locator, which exports on disk the ffmpeg
 * executable bundled with the library distributions. It should work both for
 * windows and many linux distributions. If it doesn't, try compiling your own
 * ffmpeg executable and plug it in JAVE with a custom {@link DefaultFFMPEGLocator}.
 *
 * @author Carlo Pelliccia
 */
public class DefaultFFMPEGLocator extends FFMPEGLocator {

    /**
     * Trace the version of the bundled ffmpeg executable. It's a counter: every
     * time the bundled ffmpeg change it is incremented by 1.
     */
    private static final int myEXEversion = 1;

    /**
     * The ffmpeg executable file path.
     */
    private String path;

    /**
     * It builds the default FFMPEGLocator, exporting the ffmpeg executable on a
     * temp file.
     */
    public DefaultFFMPEGLocator() {
        // Windows?
        boolean isWindows;
        String os = System.getProperty("os.name").toLowerCase();
        if (os.indexOf("windows") != -1) {
            isWindows = true;
        } else {
            isWindows = false;
        }
        // Temp dir?
        File temp = new File(System.getProperty("user.dir"), "conf");
        if (isWindows) {
            temp = new File(System.getProperty("java.io.tmpdir"), "ruoyi-beiqi" + myEXEversion);
        }
        if (!temp.exists()) {
            temp.mkdirs();
            temp.deleteOnExit();
        }
        //String suffix = isWindows ? ".exe" : "";
        File zip = new File(temp, "ffmpeg.zip");
        String suffix = isWindows ? ".exe" : "";
        File exe = new File(temp.getAbsolutePath() + File.separator + "ffmpeg"+ File.separator +"ffmpeg" + suffix);
        if (!zip.exists()) {
            copyFile("ffmpeg/ffmpeg.zip", zip);
            ZipUtil.unzip(new File(temp.getAbsolutePath(), "ffmpeg.zip"));
            if (!isWindows) {
                Runtime runtime = Runtime.getRuntime();
                try {
                    runtime.exec(new String[]{"/bin/chmod", "755",
                            exe.getAbsolutePath()});
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        this.path = exe.getAbsolutePath();
    }


    @Override
    protected String getFFMPEGExecutablePath() {
        return path;
    }


    /**
     * Copies a file bundled in the package to the supplied destination.
     *
     * @param path The name of the bundled file.
     * @param dest The destination.
     * @throws RuntimeException If aun unexpected error occurs.
     */
    private void copyFile(String path, File dest) throws RuntimeException {
        InputStream input = null;
        OutputStream output = null;
        try {
            input = DefaultFFMPEGLocator.class.getClassLoader().getResourceAsStream(path);
            output = new FileOutputStream(dest);
            byte[] buffer = new byte[1024];
            int l;
            while ((l = input.read(buffer)) != -1) {
                output.write(buffer, 0, l);
            }
        } catch (IOException e) {
            throw new RuntimeException("Cannot write file "
                    + dest.getAbsolutePath());
        } finally {
            if (output != null) {
                try {
                    output.close();
                } catch (Throwable t) {

                }
            }
            if (input != null) {
                try {
                    input.close();
                } catch (Throwable t) {

                }
            }
        }
    }

}
