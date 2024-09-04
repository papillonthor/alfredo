package org.b104.alfredo.jobs.controller;

import org.b104.alfredo.jobs.service.JobService;
import org.quartz.SchedulerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/jobs")
public class JobController {
    @Autowired
    private JobService jobService;

    @GetMapping("/list")
    public ResponseEntity<List<String>> getPendingJobs() {
        try {
            List<String> pendingJobs = jobService.getPendingJobs();
            return ResponseEntity.ok(pendingJobs);
        } catch (SchedulerException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
