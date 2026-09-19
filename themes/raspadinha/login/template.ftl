<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}"<#if locale?? && locale.currentLanguageTag??> lang="${locale.currentLanguageTag}"</#if>>

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <meta name="color-scheme" content="dark light">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />
    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript" defer></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
</head>

<body class="${properties.kcBodyClass!} ${bodyClass}">
<main class="${properties.kcLoginClass!}">

    <#-- Marca: isologo inline + nome do realm (displayNameHtml) -->
    <div id="kc-header" class="${properties.kcHeaderClass!}">
        <svg class="rs-brand-mark" width="20" height="22" viewBox="0 0 359.34 400" role="img" aria-hidden="true" focusable="false">
            <path fill="#a166ff" d="M0 369.28V400h310.74a48.5 48.5 0 0 0 48.51-48.5V200.04H169.23A169.25 169.25 0 0 0 0 369.27ZM.06 48.5v151.46h190.02A169.26 169.26 0 0 0 359.34 30.69V0H48.57A48.52 48.52 0 0 0 .06 48.5Z"/>
        </svg>
        <div id="kc-header-wrapper" class="${properties.kcHeaderWrapperClass!}">${kcSanitize(msg("loginTitleHtml",(realm.displayNameHtml!'')))?no_esc}</div>
    </div>

    <div class="${properties.kcFormCardClass!}">
        <#if realm.internationalizationEnabled && locale.supported?size gt 1>
            <div class="${properties.kcLocaleMainClass!}" id="kc-locale">
                <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
                    <details id="kc-locale-dropdown" class="${properties.kcLocaleDropDownClass!}">
                        <summary id="kc-current-locale-link">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>
                            <span class="rs-locale-current" title="${locale.current}">${(locale.currentLanguageTag)!locale.current}</span>
                        </summary>
                        <ul class="${properties.kcLocaleListClass!}">
                            <#list locale.supported as l>
                                <li class="${properties.kcLocaleListItemClass!}">
                                    <a class="${properties.kcLocaleItemClass!}" href="${l.url}">${l.label}</a>
                                </li>
                            </#list>
                        </ul>
                    </details>
                </div>
            </div>
        </#if>

        <header class="${properties.kcFormHeaderClass!}">
            <#if !(auth?has_content && auth.showUsername() && !auth.showResetCredentials())>
                <#if displayRequiredFields>
                    <div class="${properties.kcContentWrapperClass!}">
                        <h1 id="kc-page-title"><#nested "header"></h1>
                        <p class="rs-required-note"><span class="rs-required">*</span> ${msg("requiredFields")}</p>
                    </div>
                <#else>
                    <h1 id="kc-page-title"><#nested "header"></h1>
                </#if>
            <#else>
                <#if displayRequiredFields>
                    <div class="${properties.kcContentWrapperClass!}">
                        <p class="rs-required-note"><span class="rs-required">*</span> ${msg("requiredFields")}</p>
                    </div>
                </#if>
                <#nested "show-username">
                <div id="kc-username" class="rs-attempted">
                    <label id="kc-attempted-username" class="rs-attempted-name">${auth.attemptedUsername}</label>
                    <a id="reset-login" class="rs-attempted-restart" href="${url.loginRestartFlowUrl}" aria-label="${msg("restartLoginTooltip")}" title="${msg("restartLoginTooltip")}">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v5h5"/></svg>
                    </a>
                </div>
            </#if>
            <p class="rs-subtitle"><#nested "subtitle"></p>
        </header>

        <div id="kc-content">
            <div id="kc-content-wrapper">

                <#-- Ações iniciadas pela aplicação não mostram avisos de "complete a ação" durante o login. -->
                <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                    <div class="alert-${message.type} ${properties.kcAlertClass!} rs-alert-${message.type}" role="alert">
                        <span class="rs-alert-icon" aria-hidden="true">
                            <#if message.type = 'success'><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8.5 12.5 2.3 2.3 4.7-5"/></svg></#if>
                            <#if message.type = 'warning'><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3.5 21 19H3z"/><path d="M12 9.5v4"/><path d="M12 16.5v.1"/></svg></#if>
                            <#if message.type = 'error'><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 7.5v5"/><path d="M12 16.2v.1"/></svg></#if>
                            <#if message.type = 'info'><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 11v5"/><path d="M12 7.8v.1"/></svg></#if>
                        </span>
                        <span class="${properties.kcAlertTitleClass!}">${kcSanitize(message.summary)?no_esc}</span>
                    </div>
                </#if>

                <#nested "form">

                <#if auth?has_content && auth.showTryAnotherWayLink()>
                    <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post">
                        <div class="${properties.kcFormGroupClass!} rs-try-another">
                            <input type="hidden" name="tryAnotherWay" value="on"/>
                            <a href="#" id="try-another-way" class="rs-link"
                               onclick="document.forms['kc-select-try-another-way-form'].submit();return false;">${msg("doTryAnotherWay")}</a>
                        </div>
                    </form>
                </#if>

                <#nested "socialProviders">

                <#if displayInfo>
                    <div id="kc-info" class="${properties.kcSignUpClass!}">
                        <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                            <#nested "info">
                        </div>
                    </div>
                </#if>
            </div>
        </div>
    </div>

</main>
</body>
</html>
</#macro>
