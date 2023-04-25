package com.telmore.hazelcastembedded;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;

@RestController
public class CommandController {  
  @Autowired
  private HazelcastInstance hazelcastInstance;

  private IMap<String,String> retrieveMap() {
      return hazelcastInstance.getMap("map");
  }

  @PostMapping("/put")
  public CommandResponse put(@RequestParam(value = "key") String key, @RequestParam(value = "value") String value) {
      System.out.println("Put value to cache: " + key);
      String oldValue = retrieveMap().put(key, value);
      System.out.println("Old value was: " + oldValue);
      return new CommandResponse(oldValue);
  }

  @GetMapping("/get")
  public CommandResponse get(@RequestParam(value = "key") String key) {
      String value = "";
      if (retrieveMap().containsKey(key)) {
          value = retrieveMap().get(key);
      } else {
          value = "Key: " + key + " is not found in cached map";
      }
      System.out.println(value);
      return new CommandResponse(value);
  }

  @RequestMapping("/remove")
  public CommandResponse remove(@RequestParam(value = "key") String key) {
      String value = retrieveMap().remove(key);
      System.out.println("Item with key " + key + " and value " + value + " removed from map");
      return new CommandResponse(value);
  }

  @RequestMapping("/size")
  public CommandResponse size() {
      int size = retrieveMap().size();
      System.out.println("Map contains " + size + "elements");
      return new CommandResponse(Integer.toString(size));
  }

  @RequestMapping("/populate")
  public CommandResponse populate() {
      for (int i = 0; i < 1000; i++) {
          String s = Integer.toString(i);
          retrieveMap().put(s, s);
      }
      System.out.println("1000 entries inserted into the map... keys are 1 to 1000");
      return new CommandResponse("1000 entries inserted to the map... keys are 1 to 1000");
  }

  @RequestMapping("/clear")
  public CommandResponse clear() {
      retrieveMap().clear();
      System.out.println("Map cleared");
      return new CommandResponse("Map cleared");
  }

}
