<?php
// A self-contained installation test; no separately downloaded dictionary needed.
error_reporting(E_ALL);
set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});
function check($condition, $message) {
    if (!$condition) {
        throw new RuntimeException($message);
    }
}
function words($handle, $object) {
    $words = [];
    while ($result = $object ? $handle->get_result() : scws_get_result($handle)) {
        foreach ($result as $word) {
            $words[] = $word['word'];
        }
    }
    return $words;
}
check(extension_loaded('scws'), 'scws extension did not load');
foreach ([$argv[1] => SCWS_XDICT_TXT, $argv[3] => SCWS_XDICT_XDB] as $dict => $mode) {
    for ($i = 0; $i < 100; $i++) {
        $scws = scws_new();
        check($scws instanceof SimpleCWS, 'scws_new failed');
        $scws->set_charset('utf8');
        check($scws->set_dict($dict, $mode), 'Object dictionary failed');
        check($scws->set_rule($argv[2]), 'Installed rules failed');
        // Send a temporary string to exercise PHP 8.4 string/resource ownership.
        $scws->send_text(implode('', ['中文', '分詞', '測試']));
        $actual = words($scws, true);
        check($actual === ['中文', '分詞', '測試'], 'Object segmentation failed: ' . json_encode($actual, JSON_UNESCAPED_UNICODE));
        $scws->send_text(implode('', ['分詞', '測試']));
        check(words($scws, true) === ['分詞', '測試'], 'Repeated send_text failed');
        $input = implode('', ['中文', '測試']);
        $scws->send_text($input);
        $input[0] = 'x';
        unset($input);
        check(words($scws, true) === ['中文', '測試'], 'Input mutation changed pending results');
        if ($i % 2 === 0) {
            $scws->close();
        }
        unset($scws);
    }
    $handle = scws_open();
    scws_set_charset($handle, 'utf8');
    check(scws_set_dict($handle, $dict, $mode), 'Procedural dictionary failed');
    scws_set_rule($handle, $argv[2]);
    scws_send_text($handle, implode('', ['中文', '分詞', '測試']));
    check(words($handle, false) === ['中文', '分詞', '測試'], 'Procedural segmentation failed');
    scws_send_text($handle, implode('', ['中文', '測試']));
    check(words($handle, false) === ['中文', '測試'], 'Procedural repeated send_text failed');
    scws_close($handle);
}
printf("PASS: PHP %s; %s; text/XDB dictionaries, object/procedural APIs and 200 object lifecycles\n", PHP_VERSION, scws_version());
