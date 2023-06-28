package com.telmore.hazelcastembedded;

import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hazelcast.cluster.Member;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;

@RestController
public class CommandController {  
  @Autowired
  private HazelcastInstance hazelcastInstance;

  static String test_version = "Hazelcast App - Test Version 5";

  private IMap<String,String> retrieveMap() {
      return hazelcastInstance.getMap("map");
  }

  @PostMapping("/put")
  public CommandResponse put(@RequestParam(value = "key") String key, @RequestParam(value = "value") String value) {
    System.out.println(test_version);
    System.out.println("Put value to cache: " + key);
    String oldValue = retrieveMap().put(key, value);
    System.out.println("Old value was: " + oldValue);
    return new CommandResponse(oldValue);
  }

  @GetMapping("/nodes")
  public CommandResponse nodecount() {
    System.out.println(test_version);
    Set<Member> members = hazelcastInstance.getCluster().getMembers();

    String returnVal = "Members {size:" + members.size() + "}";
    System.out.println(returnVal);
    for (Member member : members) {
      returnVal = returnVal + "\n" + member.toString();
      System.out.println(member.toString());
    }
    return new CommandResponse(returnVal);
  }

  @GetMapping("/get")
  public CommandResponse get(@RequestParam(value = "key") String key) {
    System.out.println(test_version);
    String value = "";
    System.out.println("Change code in get");
    if (retrieveMap().containsKey(key)) {
        value = retrieveMap().get(key);
    } else {
        value = "Key: " + key + " is not found in cached map";
    }
    System.out.println("Get key: " + key + " value: " + value);
    return new CommandResponse(value);
  }

  @RequestMapping("/remove")
  public CommandResponse remove(@RequestParam(value = "key") String key) {
    System.out.println(test_version);
    String value = retrieveMap().remove(key);
    System.out.println("Item with key " + key + " and value " + value + " removed from map");
    return new CommandResponse(value);
  }

  @RequestMapping("/size")
  public CommandResponse size() {
    System.out.println(test_version);
    int size = retrieveMap().size();
    System.out.println("Map contains " + size + " elements");
    return new CommandResponse(Integer.toString(size));
  }

  @RequestMapping("/populate")
  public CommandResponse populate() {
    System.out.println(test_version);
    for (int i = 0; i < 1000; i++) {
        String s = Integer.toString(i);
        retrieveMap().put(s, s);
    }
    String returnVal = "1000 entries inserted into the map... keys are 1 to 1000";
    System.out.println(returnVal);
    return new CommandResponse(returnVal);
  }

  @RequestMapping("/clear")
  public CommandResponse clear() {
    System.out.println(test_version);
    retrieveMap().clear();
    System.out.println("Map cleared");
    return new CommandResponse("Map cleared");
  }

}
