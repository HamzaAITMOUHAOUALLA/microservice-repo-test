package com.example.datademo.controller;

import com.example.datademo.service.FileService;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/files")
public class FileController {

    private final FileService fileService;

    public FileController(FileService fileService) {
        this.fileService = fileService;
    }

    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> upload(
            @RequestParam("file") MultipartFile file) throws Exception {

        String id = fileService.save(file);
        return ResponseEntity.ok(Map.of("fileId", id));
    }

    @PostMapping("/process/{id}")
    public ResponseEntity<Void> process(@PathVariable String id) throws Exception {
        fileService.compress(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> download(@PathVariable String id) throws Exception {
        Resource file = fileService.get(id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=result.zip")
                .body(file);
    }
}