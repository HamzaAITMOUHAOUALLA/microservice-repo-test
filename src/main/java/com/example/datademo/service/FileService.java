package com.example.datademo.service;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class FileService {

    private final Path root = Paths.get("storage");

    public FileService() throws IOException {
        Files.createDirectories(root);
    }

    public String save(MultipartFile file) throws IOException {
        String id = UUID.randomUUID().toString();
        Files.copy(file.getInputStream(), root.resolve(id));
        return id;
    }

    public void compress(String id) throws IOException {
        Path source = root.resolve(id);
        Path zipPath = root.resolve(id + ".zip");

        try (ZipOutputStream zs =
                     new ZipOutputStream(Files.newOutputStream(zipPath))) {
            zs.putNextEntry(new ZipEntry("original"));
            Files.copy(source, zs);
            zs.closeEntry();
        }
    }

    public Resource get(String id) {
        Path file = root.resolve(id + ".zip");
        return new FileSystemResource(file);
    }
}