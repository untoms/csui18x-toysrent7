package id.csui.bazdat.toysrent.config.security;

import id.csui.bazdat.toysrent.model.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

public class CustomUserDetails implements UserDetails {

    public final String ROLE_ADMIN = "ROLE_ADMIN";
    public final String ROLE_MEMBER  = "ROLE_MEMBER";

    private User user;

    public CustomUserDetails(User user) {
        this.user = user;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {

        if (user.isAdmin())
            return AuthorityUtils.commaSeparatedStringToAuthorityList(ROLE_ADMIN);

        return AuthorityUtils.commaSeparatedStringToAuthorityList(ROLE_MEMBER);
    }

    @Override
    public String getPassword() {
        return user.getNoKtp();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
