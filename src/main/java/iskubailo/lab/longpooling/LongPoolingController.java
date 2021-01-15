package iskubailo.lab.longpooling;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Optional;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Controller
@RequestMapping
public class LongPoolingController {

    private final AtomicInteger counter = new AtomicInteger();
    private final AtomicInteger sequence = new AtomicInteger(1);
    private final AtomicInteger requestCount = new AtomicInteger();
    private final BlockingQueue<Integer> blockingQueue = new ArrayBlockingQueue<>(1);

    @GetMapping("/api/get")
    @ResponseBody
    int getCounter() {
        return counter.get();
    }

    @GetMapping("/api/increment")
    @ResponseBody
    int incCounter() {
        int newValue = counter.incrementAndGet();
        blockingQueue.offer(newValue);
        return getCounter();
    }

    @GetMapping("/api/fetch/{browserId}/{old}")
    @ResponseBody
    int fetch(@PathVariable String browserId, @PathVariable("old") int oldValue) throws InterruptedException {
        int requestId = sequence.incrementAndGet();
        log.info("fetch #{} [{}] ({} requests active)", requestId, browserId, requestCount.incrementAndGet());
        long start = System.currentTimeMillis();
        int value;
        int newValue = counter.get();
        if (newValue == oldValue) {
            value = Optional.ofNullable(blockingQueue.poll(10, TimeUnit.SECONDS)).orElse(newValue);
        } else {
            value = newValue;
        }
        long end = System.currentTimeMillis();
        log.info("result #{} [{}] in {} ms ({} requests active): {}", requestId, browserId, (end - start), requestCount.decrementAndGet(), value);
        return value;
    }

    @GetMapping
    public String index() {
        return "index";
    }
}
