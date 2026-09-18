<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        ${msg("loginAccountTitle")}
    <#elseif section = "subtitle">
        ${msg("raspalaLoginSubtitle")}
    <#elseif section = "form">
    <div id="kc-form">
      <div id="kc-form-wrapper">
        <#if realm.password>
            <form id="kc-form-login" class="${properties.kcFormClass!}" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post" novalidate>
                <#if !usernameHidden??>
                    <div class="${properties.kcFormGroupClass!}<#if messagesPerField.existsError('username','password')> ${properties.kcFormGroupErrorClass!}</#if>">
                        <label for="username" class="${properties.kcLabelClass!}"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>

                        <input tabindex="1" id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="username" spellcheck="false" autocapitalize="none"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                        />

                        <#if messagesPerField.existsError('username','password')>
                            <span id="input-error" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                    ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </#if>

                <div class="${properties.kcFormGroupClass!}<#if messagesPerField.existsError('username','password')> ${properties.kcFormGroupErrorClass!}</#if>">
                    <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>

                    <div class="rs-input-wrap">
                        <input tabindex="2" id="password" class="${properties.kcInputClass!}" name="password" type="password" autocomplete="current-password"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                        />
                        <button class="rs-toggle" type="button" data-password-toggle="password"
                                aria-label="${msg("raspalaShowPassword")}" data-label-show="${msg("raspalaShowPassword")}" data-label-hide="${msg("raspalaHidePassword")}"
                                aria-controls="password" aria-pressed="false" tabindex="-1">
                            <svg class="rs-toggle-show" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                <path d="M2 12s3.6-6.5 10-6.5S22 12 22 12s-3.6 6.5-10 6.5S2 12 2 12Z"/>
                                <circle cx="12" cy="12" r="2.8"/>
                            </svg>
                            <svg class="rs-toggle-hide" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" hidden>
                                <path d="M4 4l16 16"/>
                                <path d="M9.6 9.7A2.8 2.8 0 0 0 12 14.8c.7 0 1.4-.3 1.9-.8"/>
                                <path d="M6.3 6.6C3.6 8.3 2 12 2 12s3.6 6.5 10 6.5c1.9 0 3.5-.5 4.9-1.2"/>
                                <path d="M19.5 15.8C21.2 14.2 22 12 22 12s-3.6-6.5-10-6.5c-.9 0-1.7.1-2.4.3"/>
                            </svg>
                        </button>
                    </div>

                    <#if usernameHidden?? && messagesPerField.existsError('username','password')>
                        <span id="input-error" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                        </span>
                    </#if>
                </div>

                <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                    <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                        <#if realm.rememberMe && !usernameHidden??>
                            <label class="${properties.kcInputClassCheckbox!}" for="rememberMe">
                                <#if login.rememberMe??>
                                    <input tabindex="3" id="rememberMe" class="${properties.kcInputClassCheckboxInput!}" name="rememberMe" type="checkbox" checked>
                                <#else>
                                    <input tabindex="3" id="rememberMe" class="${properties.kcInputClassCheckboxInput!}" name="rememberMe" type="checkbox">
                                </#if>
                                <span class="${properties.kcInputClassCheckboxLabel!}">${msg("rememberMe")}</span>
                            </label>
                        </#if>
                    </div>
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <#if realm.resetPasswordAllowed>
                            <a tabindex="5" class="rs-link" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                        </#if>
                    </div>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <input tabindex="4" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit" value="${msg("doLogIn")}"/>
                </div>
            </form>
        </#if>
      </div>
    </div>
    <#elseif section = "info" >
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration-container">
                <div id="kc-registration">
                    <span>${msg("noAccount")} <a tabindex="6" class="rs-link" href="${url.registrationUrl}">${msg("doRegister")}</a></span>
                </div>
            </div>
        </#if>
    <#elseif section = "socialProviders" >
        <#if realm.password && social.providers??>
            <div id="kc-social-providers" class="${properties.kcFormSocialAccountSectionClass!}">
                <div class="rs-separator"><span>${msg("identity-provider-login-label")}</span></div>

                <ul class="${properties.kcFormSocialAccountListClass!} <#if social.providers?size gt 3>${properties.kcFormSocialAccountListGridClass!}</#if>">
                    <#list social.providers as p>
                        <li class="<#if social.providers?size gt 3>${properties.kcFormSocialAccountGridItem!}</#if>">
                            <a id="social-${p.alias}" class="${properties.kcFormSocialAccountListButtonClass!}" type="button" href="${p.loginUrl}">
                                <#if p.iconClasses?has_content>
                                    <i class="${properties.kcCommonLogoIdP!} ${p.iconClasses!}" aria-hidden="true"></i>
                                    <span class="${properties.kcFormSocialAccountNameClass!} kc-social-icon-text">${p.displayName!}</span>
                                <#else>
                                    <span class="${properties.kcFormSocialAccountNameClass!}">${p.displayName!}</span>
                                </#if>
                            </a>
                        </li>
                    </#list>
                </ul>
            </div>
        </#if>
    </#if>

</@layout.registrationLayout>
