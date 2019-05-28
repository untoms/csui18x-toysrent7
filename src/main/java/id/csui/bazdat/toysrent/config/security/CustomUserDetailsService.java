package id.csui.bazdat.toysrent.config.security;

import id.csui.bazdat.toysrent.model.User;
import id.csui.bazdat.toysrent.repository.UserRepository;
import id.csui.bazdat.toysrent.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class CustomUserDetailsService implements UserDetailsService {

    Logger logger = LoggerFactory.getLogger(this.getClass());

    private final UserRepository userRepository;

    @Autowired
    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        User user = userRepository.getUerByUserName(username);

        if (user == null) {
            throw new UsernameNotFoundException("Invalid username or password!");
        }

        logger.debug("USER : "+user.toString());

        return new CustomUserDetails(user);
    }
}
