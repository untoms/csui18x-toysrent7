package id.csui.bazdat.toysrent.service;

import id.csui.bazdat.toysrent.model.User;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class UserService {

    private Map<String, User> data = new HashMap<>();


    public User getUerByUserName(String userName){

        data.put("admin01@toysrent.com", new User("001", "admin01@toysrent.com", "Admin 01", "085747758222", new Date(), null, 0.0f, true));
        data.put("member01@toysrent.com", new User("002", "member01@toysrent.com", "Member 01", "085747758222", new Date(), null, 0.0f, false));

        return data.get(userName);

    }

}
